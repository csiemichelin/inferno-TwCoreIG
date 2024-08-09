# -*- coding: UTF-8 -*-
import os
import json
import uuid
from flask import jsonify, request, make_response
from threading import Lock
from __main__ import verification_queue
from pymongo import MongoClient
from datetime import datetime, timedelta
import time
# from queue import Queue

# 創建一個隊列來儲存 待驗證的 JSON 表單和對應的新id
# verification_queue = Queue()

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
        id_list.append(item[1])  # 只提取bundle_id
    print(str(id_list))
    
    for item in temp_list:
        queue.put(item)
        
def create_validations(body):
    body = request.get_json()
    bundles = body.get('bundles', [])
    request_id = generate_short_uuid()
    # 取得當前時間
    create_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # 連接到 MongoDB
    client = MongoClient('mongodb://192.168.43.135:27017/')
    db = client['TWCoreIGValidation']
    collection = db['requests']
    
    # 準備要插入的資料
    records = []
    bundle_ids = []
    for bundle in bundles:
        original_id = bundle.get('id', '')
        generate_id = generate_short_uuid()
        bundle_id = generate_id + original_id
        bundle['id'] = bundle_id
        # 將表單加入到待驗證隊列中
        verification_queue.put((json.dumps(bundle), bundle_id, request_id))
        # print("昆霖測試bundle_id = " + str(bundle_id))
        # print_queue_contents(verification_queue)
        bundle_ids.append(bundle_id)
        
    records.append({
        'request_id': request_id,
        'bundle_ids': bundle_ids,
        'create_time': create_time,
    })

    # request_id 對應到多個bundle_id，寫到mongoDB裡
    # 將資料插入到 requests 集合中
    collection.insert_many(records)
    
    # client.close()
    
    # 等待並輪詢直到 validation_messages 存在
    max_wait_time = timedelta(seconds=60)  # 最大等待時間（秒）
    poll_interval = 1  # 輪詢間隔（秒）
    start_time = datetime.now()

    while datetime.now() - start_time < max_wait_time:
        inserted_record = collection.find_one({'request_id': request_id})
        if 'validation_messages' in inserted_record:
            break
        time.sleep(poll_interval)

    client.close()

    if 'validation_messages' in inserted_record:
        response = {
            "message": "Validations completed successfully",
            "request_details": {
                "request_id": inserted_record['request_id'],
                "bundle_ids": inserted_record['bundle_ids'],
                "create_time": inserted_record['create_time'],
                "validation_messages": inserted_record['validation_messages']
            }
        }
        return jsonify(response), 200
    else:
        response = {
            "message": "Validation results not available within the expected time",
            "request_id": request_id
        }
        return jsonify(response), 202  # 202 Accepted