import os
import shutil
import ssl
import json
import re
import connexion
import copy
from pymongo import MongoClient
from swagger_server import encoder
from flask_apscheduler import APScheduler
from threading import Thread, Lock
# from swagger_server.controllers.validation_controller import verification_queue
from queue import Queue

# 創建一個隊列來儲存 待驗證的 JSON 表單和對應的新id
verification_queue = Queue()

# 全局變量，保存每個input文件的狀態（是否空閒）1~10 => range(1, 11)
# file_status = {f'input/bundle-{i:02}.json': 'idle' for i in range(1, 4)}
file_status = {f'input/bundle-{i:02}.json': 'idle' for i in range(1, 11)}

# 全局變量，保存每個input文件的狀態的cli_message，初始值為空
# climessage_list = {f'input/bundle-{i:02}.json': '' for i in range(1, 4)}
climessage_list = {f'input/bundle-{i:02}.json': '' for i in range(1, 11)}

# 創建一個Quee紀錄每個輸入的cli_message(每次monitor執行時固定撈idle狀態的cli_message，當busy檢查該檔案是否跟此list的值不同)
context = ssl.SSLContext()

lock = Lock()

# 創建一個鎖來保護 file_status(後面的變更file_status_lock操作要等待前面的操作完成)
file_status_lock = Lock()

def create_app():
    context.load_cert_chain("cert.pem", "key.pem")

    app = connexion.FlaskApp(__name__, specification_dir="swagger/")
    app.json_encoder = encoder.JSONEncoder
    app.json_encoder.ensure_ascii = False
    app.json_encoder.encoding = "utf-8"

    app.add_api(
        "swagger.yaml",
        arguments={"title": "Judicial 30X API", "swagger_ui": False},
        pythonic_params=True,
    )

    return app

# 用鎖保護狀態
def update_file_status(file_path, status):
    with file_status_lock:
        file_status[file_path] = status

# 判定字串是否合規json格式
def is_valid_json_string(json_string):
    try:
        json.loads(json_string)
        return True
    except (ValueError, json.JSONDecodeError) as e:
        print(f"Invalid JSON string: {e}")
        return False
    
# 判定文件是否包含合法的 JSON
def is_valid_json_file(file_path):
    try:
        with open(file_path, 'r') as f:
            data = f.read()
        json.loads(data)
        return True
    except (ValueError, json.JSONDecodeError, FileNotFoundError) as e:
        print(f"Invalid JSON or file not found in {file_path}: {e}")
        return False

# 輸出Queue的內容
def print_queue_contents(queue):
    temp_list = []
    id_list = []
    while not queue.empty():
        item = queue.get()
        temp_list.append(item)
    
    print("Queue contents:")
    for item in temp_list:
        # print(item)
        id_list.append(item[1])  # 只提取new_id
    print(str(id_list))
    
    for item in temp_list:
        queue.put(item)


# 尋找空閒的文件路徑
def find_idle_file():
    for file_path, status in file_status.items():
        if status == 'idle':
            return file_path
    return None

# 檢查有沒有相對應的ouput文件:[bundle_id].json，且該json也符合json格式
def check_ouput_file_exist(id):
    file_to_check = f"output_bundleID/{id}.json"
    
    if os.path.exists(file_to_check) and is_valid_json_file(file_to_check):
        # print(f"The file '{file_to_check}' exists and is valid.")
        return True
    else:
        # print(f"The file '{file_to_check}' does not exist or not valid.")
        return False

# 從outputcli.txt中提取cli_message字串
def extract_done_times_line(outputcli_file):
    with open(outputcli_file, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if "Done. Times: Loading:" in line:
                return line.strip()
    return None

# 檢查是否完成驗證，檢查outputcli.txt是否有cli_message(e.g: Done. Times: Loading: 00:28.376, validation: 00:04.710 (#4). Memory = 762Mb)
# 和Watching for changes (1000ms cycle)字串
def finished_validation(file_path):
    # 抓取編號值
    file_num = ""
    outputcli_file = ""
    match = re.search(r'input/bundle-(\d{2})\.json', file_path)
    if match:
        file_num = match.group(1)
        outputcli_file = f'output_cli/outputcli-{file_num}.txt'
    # 檢查outputcli.txt是否有cli_message(e.g: Done. Times: Loading: 00:28.376, validation: 00:04.710 (#4). Memory = 762Mb)
    # 和Watching for changes (1000ms cycle)字串
    with open(outputcli_file, 'r') as f:
        content = f.read()
        if "Done. Times: Loading:" in content and "Watching for changes (1000ms cycle)" in content:
            # print(f"'{outputcli_file}' cli_message exist")
            # 檢查climessage_list中的cli_message，是否和 outputcli.txt中的cli_message相同
            climessage_file = extract_done_times_line(outputcli_file)
            # print("昆霖測試 climessage_file = " + str(climessage_file))
            # print("昆霖測試 climessage_list[file_path] = " + str(climessage_list[file_path]))
            
            # 若outputcli.txt的cli_message和climessage_list中的cli_message不同則代表驗證完畢
            if climessage_list[file_path] != climessage_file or climessage_list[file_path] == '':
                # 更新climessage_list中的cli_message
                climessage_list[file_path] = climessage_file
                return True
            else:
                return False
        else:
            print(f"'{outputcli_file}' cli_message does not exist")
            return False

#  檢查outputcli-[XX].json是否存在且格式正確，若存在檢查是否驗證完畢，再複製outputcli-[XX].json到[bundle_id].json，複製完畢才將狀態調整為idle
def check_bundle_id_json_existed(file_path, outputcli_file, id):
    bundle_id_json = f"output_bundleID/{id}.json"
    # 若存在outputcli-[XX].json
    if os.path.exists(outputcli_file):
        with open(outputcli_file, 'r') as f:
            # 讀取 outputcli-[XX].json 的内容
            content = f.read()
            if "Done. Times: Loading:" in content and "Watching for changes (1000ms cycle)" in content:
                # 將内容追加到 [bundle_id].json
                with open(bundle_id_json, 'r+', encoding='utf-8') as f:
                    try:
                        existing_data = json.load(f)
                    except json.JSONDecodeError:
                        existing_data = {"validate_message": []}

                    if isinstance(existing_data, dict) and isinstance(existing_data.get("validate_message"), list):
                        existing_data["validate_message"].append(content)
                    else:
                        raise ValueError("Unexpected JSON structure")

                    f.seek(0)
                    json.dump(existing_data, f, ensure_ascii=False, indent=2)
                    f.truncate()
                    
                print(f"Copied {outputcli_file} to {bundle_id_json}")
                print(f"{id}產生驗證文件，釋放input空間，調整狀態為idle")
                update_file_status(file_path, 'idle')
            # else:
            #     update_file_status(file_path, 'busy')
    
def get_bundle_id(file_path):
    try:
        with open(file_path, 'r') as f:
            data = f.read()
        json_data = json.loads(data)
        # 提取request id
        if 'id' in json_data:
            id_value = json_data['id']
            id_value_first_10_chars = id_value[:10]
            print(f"The first 10 characters of the 'id' value are: {id_value_first_10_chars}")
        else:
            print("'id' key not found in the JSON data.")
        return id_value_first_10_chars
    except (ValueError, json.JSONDecodeError, FileNotFoundError) as e:
        print(f"Invalid JSON or file not found in {file_path}: {e}")
        return None

# 監控需要將文件調整狀態為idle，
# 首先: 先檢查符合JSON格式且狀態為busy的input文件是否完成驗證
# 若完成驗證: 檢查[bundle_id].json是否存在
#   若不存在: 創建[bundle_id].json
#   判斷檢查outputcli-[XX].json是否存在且格式正確
#       若滿足:  複製outputcli-[XX].json到[bundle_id].json，複製完畢才將狀態調整為idle
#       若不滿足: 維持狀態為busy       
# 若還沒完成驗證: 維持狀態不變(可能根本沒有需要驗證的不一定是busy)
def changeto_idle_file():
    for file_path in file_status.keys():
        # 先檢查符合JSON格式且狀態為busy的input文件
        if is_valid_json_file(file_path) and file_status[file_path] == 'busy':
            # 檢查是否完成驗證
            if finished_validation(file_path) == True:
                id = get_bundle_id(file_path)
                if id != None:
                    # 檢查[bundle_id].json是否存在
                    chk_flag = check_ouput_file_exist(id)
                    # 如果不存在 [bundle_id].json則創建檔案 
                    if chk_flag == False:
                        bundle_id_json = f"output_bundleID/{id}.json"
                        if not os.path.exists(bundle_id_json):
                            initial_data = {
                                "validate_message": []
                            }
                            with open(bundle_id_json, 'w', encoding='utf-8') as f:
                                json.dump(initial_data, f, ensure_ascii=False, indent=2)
                    # 檢查outputcli-[XX].json是否存在且格式正確，把outputcli-[XX].json添加到bundle_id_json中
                    file_num = ""
                    match = re.search(r'input/bundle-(\d{2})\.json', file_path)
                    if match:
                        file_num = match.group(1)
                    outputcli_file = f'output_cli/outputcli-{file_num}.txt'
                    # 檢查outputcli-[XX].json是否存在且格式正確，若存在檢查是否驗證完畢，再複製outputcli-[XX].json到[bundle_id].json，複製完畢才將狀態調整為idle
                    check_bundle_id_json_existed(file_path, outputcli_file, id)

# 監控是否所有request_id對應的bundle_ids都驗證完了若驗證完提取關鍵字寫入到output_bundleID.json中並刪除output_requestID.json    
def check_all_bundles_validated():
    # 連接到 MongoDB
    client = MongoClient('mongodb://192.168.43.135:27017/')
    db = client['TWCoreIGValidation']
    collection = db['requests']
    
    # 查詢所有的記錄
    cursor = collection.find({})
    
    # 準備結果列表
    results = []
    
    for document in cursor:
        # 提取 request_id 和 bundle_ids
        request_id = document.get('request_id')
        bundle_ids = document.get('bundle_ids', [])
        
        # 查找是否已經存在此 request_id
        existing_record = next((item for item in results if item['request_id'] == request_id), None)
        
        if existing_record:
            # 如果存在，添加新的 bundle_ids
            existing_record['bundle_ids'].extend(bundle_ids)
        else:
            # 如果不存在，創建新的元素
            results.append({
                'request_id': request_id,
                'bundle_ids': bundle_ids
            })
        
    if results:
        # print("昆霖測試 results = " + str(results))
        
        for result in results:
            # 初始化最終輸出
            output = {"validation_output": []}
            request_id = result['request_id']
            bundle_ids = result['bundle_ids'] 
            request_id_path = os.path.join("output_requestID/", f"{request_id}.json")
            # 如果request_id.json不存在，才需要將所有request_id對應的bundle_ids複製過去
            if not os.path.exists(request_id_path):
                all_exists_flag = True 
                for bundle_id in bundle_ids:
                    # 取得前10碼作為 bundle_id
                    bundle_id_prefix = bundle_id[:10]
                    
                    # 檢查檔案是否存在
                    bundle_id_path = os.path.join("output_bundleID/", f"{bundle_id_prefix}.json")
                    
                    # 檢查所有request_id對應的bundle_ids都驗證完且產生完畢
                    if os.path.exists(bundle_id_path):
                        with open(bundle_id_path, 'r') as f:
                            content = f.read()
                            if "Done. Times: Loading:" not in content or "Watching for changes (1000ms cycle)" not in content:
                                all_exists_flag = False # 沒有全部驗證完畢
                            # else:
                            #     print(f"File {bundle_id_prefix}.json exists for request_id: {request_id}")
                    else:
                        all_exists_flag = False # 沒有全部驗證完畢

                # 若全部驗證完畢則把所有bundle_id.json提取關鍵字，存到request_id.json，並刪除對應的所有bundle_id.json
                if all_exists_flag == True:
                    for bundle_id in bundle_ids:
                        # 取得前10碼作為 bundle_id
                        bundle_id_prefix = bundle_id[:10]
                        remaining_bundle_id = bundle_id[10:]
                        
                        # 檢查檔案是否存在
                        bundle_id_path = os.path.join("output_bundleID/", f"{bundle_id_prefix}.json")
                        # 提取bundle_ids的validation message
                        if os.path.exists(bundle_id_path):
                            with open(bundle_id_path, 'r') as f:
                                content = f.read() 
                                # 解析 JSON 內容
                                content_dict = json.loads(content)
                                validate_message = content_dict.get("validate_message", [""])[0]
                                # 使用正則表達式來匹配 Done. Times 和 Watching for changes 之間的內容
                                pattern = re.compile(r'Done\. Times:.*?Memory = \d+Mb\n\n(.*?)\nWatching for changes', re.DOTALL)
                                match = pattern.search(validate_message)

                                if match:
                                    extracted_content = match.group(1)
                                    # print("昆霖測試extracted_content = " + extracted_content)
                                    output["validation_output"].append({
                                        "bundle_id": remaining_bundle_id,
                                        "validation_message": extracted_content
                                    })
                    # 將最終結果寫入 request_id.json 文件
                    with open(request_id_path, 'w') as f:
                        json.dump(output, f, indent=4, ensure_ascii=False)
                        
                    # 將 request_id_path 的內容寫入到 MongoDB 中
                    with open(request_id_path, 'r') as f:
                        validation_message_content = json.load(f)
                        
                        # 提取 validation_messages
                        validation_output = validation_message_content["validation_output"]
                        
                        # 更新 MongoDB 中對應的記錄
                        collection.update_one(
                            {'request_id': request_id},
                            {'$set': {'validation_messages': validation_output}}
                        )
                    
                    # 產生完request_id.json後刪除所有對應的bundle_id.json
                    for bundle_id in bundle_ids:
                        bundle_id_prefix = bundle_id[:10]
                        bundle_id_path = os.path.join("output_bundleID/", f"{bundle_id_prefix}.json")
                        if os.path.exists(bundle_id_path):
                            # 刪除文件
                            os.remove(bundle_id_path)
                        
    client.close()


# 監控文件變化調整狀態為idle，並觸發驗證會複寫idle的檔案
def monitor_files():  
    with lock:  # lock 確保每次只有一個線程能夠執行 monitor_files 函數，從而避免了併發訪問 verification_queue 和 file_status
        # print(f"verification_queue address = {id(verification_queue)}")
        print("verification_queue size = " + str(verification_queue.qsize()))
        print("file_status = " + str(file_status))
        # 監控有沒有需要將input文件調整狀態為idle(檢查ouput文件是否寫到[bundle_id]_output.json)
        changeto_idle_file()
        # 監控是否所有request_id對應的bundle_ids都驗證完了若驗證完提取關鍵字寫入到output_bundleID.json中並刪除output_requestID.json
        check_all_bundles_validated()
        # print_queue_contents(verification_queue)
        if not verification_queue.empty():
            json_form = verification_queue.get()
            bundle_json, bundle_id, request_id = json_form
            print(f"從verification_queue中取出: {bundle_id}")
            file_path = find_idle_file()
            if file_path != None:
                # 若json合規且有狀態為idle的，則要把input檔案狀態改為busy，且把json轉成有reuest_id的json存到input檔案中
                if is_valid_json_string(bundle_json) and file_status[file_path] == 'idle':
                    update_file_status(file_path, 'busy')
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(bundle_json)
                    # print("file_status: " + str(file_status))
                    print(f'將取出的body放入到input文件 {file_path}')
        # else:
        #     print(f'verification_queue is empty.')

# 全域變數初始化
def initialize():
    global verification_queue
    verification_queue = Queue()
    
    global file_status 
    file_status = {f'input/bundle-{i:02}.json': 'idle' for i in range(1, 4)}
    
    global climessage_list
    climessage_list = {f'input/bundle-{i:02}.json': '' for i in range(1, 4)}
                
if __name__ == "__main__":
    app = create_app()

    # Initialize the scheduler with the actual Flask application instance
    # 在Flask-APScheduler中，預設使用thread創建執行序默認的thread pool大小是10，若沒有可用的thread則會排隊等待釋放的thread
    scheduler = APScheduler()
    scheduler.init_app(app.app)
    scheduler.start()
    
    # 全域變數初始
    # initialize()  
    
    # Add scheduled task
    scheduler.add_job(id='ScheduledTask', func=monitor_files, trigger='interval', seconds=1)

    # Run the Flask application
    api_port = 10000
    # 不能加（debug=True），當 Flask 在偵錯模式下執行時（debug=True），它會啟動兩個程序。一個是主進程，另一個是用於重新載入的子進程。這會導致 initialize() 被呼叫兩次，每次都會建立新的 Queue 實例
    app.run(ssl_context=context, port=api_port, threaded=True)
