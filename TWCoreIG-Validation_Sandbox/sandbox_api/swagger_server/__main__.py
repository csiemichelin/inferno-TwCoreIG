import os
import shutil
import ssl
import json
import re
import connexion
import copy
import requests
import uuid
from pymongo import MongoClient
from swagger_server import encoder
from flask_apscheduler import APScheduler
from flask import jsonify, request, make_response
from threading import Thread, Lock
from datetime import datetime, timedelta
# from swagger_server.controllers.validation_controller import verification_queue
from queue import Queue

# 創建一個隊列來儲存 待驗證的 JSON 表單和對應的 Request ID
verification_queue = Queue()

# 創建一個Quee紀錄每個輸入的cli_message(每次monitor執行時固定撈idle狀態的cli_message，當busy檢查該檔案是否跟此list的值不同)
context = ssl.SSLContext()

lock = Lock()

# 用於生成6位數UUID的計數器和鎖
counter = 0
counter_lock = Lock()
def generate_short_uuid():
    global counter
    with counter_lock:
        counter += 1
        if counter > 999999:
            counter = 1
        # 取UUID的前4位和計數器的6位組成新的ID
        uuid_part = str(uuid.uuid4())[:4]
        counter_part = str(counter).zfill(6)
        return uuid_part + counter_part

# 判定字串是否合規json格式
def is_valid_json_string(json_string):
    try:
        json.loads(json_string)
        return True
    except (ValueError, json.JSONDecodeError) as e:
        print(f"Invalid JSON string: {e}")
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

def monitor_validations():
    with lock:  # lock 確保每次只有一個線程能夠執行 monitor_files 函數，從而避免了併發訪問 verification_queue
        # 連接到 MongoDB
        client = MongoClient('mongodb://192.168.43.135:27017/')
        db = client['TWCoreIGValidation']
        collection = db['requests']
        
        print_queue_contents(verification_queue)
        
        # 若Queue中有需要驗證的Resource呼叫驗證API
        if not verification_queue.empty():
            json_form = verification_queue.get()
            bundle_json, request_id = json_form
            print(f"從verification_queue中取出: {request_id}")
            
            # 将 bundle_json 作为请求体發送驗證 API
            url = "https://localhost/validatorapi/validate"
            headers = {'Content-Type': 'application/json'}
            
            try:
                response = requests.post(url, json=bundle_json, headers=headers, verify=False)  # verify=False 用於忽略自簽名證書
                response_validation_data = response.json()  # 假設 API 返回 JSON 響應
                
                # 提取 response 中的 issue 列表
                issues = response_validation_data.get("issue", [])
                # print("issuses = " + str(issues))
                extracted_issues = []
                
                for issue in issues:
                    # 初始化 issue-line
                    issue_line = None
                    
                    print("extension: " + str(issue.get("extension", [])))
                          
                    # 遍历 extension 列表
                    for extension in issue.get("extension", []):
                        if extension.get("url") == "http://hl7.org/fhir/StructureDefinition/operationoutcome-issue-line":
                            issue_line = extension.get("valueInteger")
                            break  
                        
                    # 提取 severity, code, details 信息
                    extracted_issue = {
                        "issue-line": issue_line,
                        "severity": issue.get("severity"),
                        "code": issue.get("code"),
                        "details": issue.get("details", {}).get("text")
                    }
                    extracted_issues.append(extracted_issue)
                
                # 更新 MongoDB 中對應的記錄
                collection.update_one(
                    {'request_id': request_id},
                    {'$set': {'validation_messages': extracted_issues}}
                )
                
                # 處理響應
                # print(f"收到的響應: {response_validation_data}")
            except requests.exceptions.RequestException as e:
                print(f"請求發生錯誤: {e}")

def create_app():
    context.load_cert_chain("cert.pem", "key.pem")

    app = connexion.FlaskApp(__name__, specification_dir="swagger/")
    app.json_encoder = encoder.JSONEncoder
    app.json_encoder.ensure_ascii = False
    app.json_encoder.encoding = "utf-8"

    app.add_api(
        "swagger.yaml",
        arguments={"title": "Inferno Fhir Validation API", "swagger_ui": False},
        pythonic_params=True,
    )

    return app

if __name__ == "__main__":
    app = create_app()

    # Initialize the scheduler with the actual Flask application instance
    # 在Flask-APScheduler中，預設使用thread創建執行序默認的thread pool大小是10，若沒有可用的thread則會排隊等待釋放的thread
    scheduler = APScheduler()
    scheduler.init_app(app.app)
    scheduler.start() 
    
    # Add scheduled task
    scheduler.add_job(id='ScheduledTask', func=monitor_validations, trigger='interval', seconds=1)

    # Run the Flask application
    api_port = 10000
    # 不能加（debug=True），當 Flask 在偵錯模式下執行時（debug=True），它會啟動兩個程序。一個是主進程，另一個是用於重新載入的子進程。這會導致 initialize() 被呼叫兩次，每次都會建立新的 Queue 實例
    app.run(ssl_context=context, port=api_port, threaded=True)
