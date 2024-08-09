# -*- coding: UTF-8 -*-
# 將Request新增到MongoDB，且等待驗證完畢後回傳，並更新數據庫
import os
import json
import uuid
import time
from flask import jsonify, request, make_response, Response
from threading import Lock
from __main__ import verification_queue
from pymongo import MongoClient
from datetime import datetime, timedelta
from collections import OrderedDict

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

def get_all_entries():
    try:
        client = MongoClient('mongodb://192.168.56.1:27017/')
        db = client['TWCoreIGValidation']
        collection = db['requests']
        # 從 MongoDB 查詢所有文檔
        documents = list(collection.find({}, {'_id': False}))  # 不返回 _id 字段
        return jsonify(documents)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

def create_validations(body):
    body = request.get_json()
    # print("body = " + str(body))
    request_id = generate_short_uuid()
    # 取得當前時間
    create_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # 連接到 MongoDB
    client = MongoClient('mongodb://192.168.56.1:27017/')
    db = client['TWCoreIGValidation']
    collection = db['requests']
    
    # 將Body內容餵給驗證器
    records = []
    
    # 將表單加入到待驗證隊列中
    verification_queue.put((body, request_id))
        
    records.append({
        'request_id': request_id,
        'create_time': create_time,
        "transaction_bundles": body,
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
                "create_time": inserted_record['create_time'],
                "validation_messages": inserted_record['validation_messages']
            }
        }
        json_str = json.dumps(response, ensure_ascii=False)
        return Response(json_str, mimetype='application/json'), 200
    else:
        response = {
            "message": "Validation results not available within the expected time",
            "request_id": request_id
        }
        json_str = json.dumps(response, ensure_ascii=False)
        return Response(json_str, mimetype='application/json'), 202  # 202 Accepted