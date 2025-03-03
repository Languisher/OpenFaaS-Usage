import requests
import logging
import json

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')


def handle(req):
    """handle a request to the function
    Args:
        req (str): request body
    """
    
    logging.info(f'receive data: {req}')
    
    req = json.loads(req)
    current_len = int(req['current_len'])
    max_len = int(req['max_len'])
    request_id = req['request_id']
    
    current_len += 1
    
    if current_len < max_len:
        req_data = {"current_len": current_len, "max_len": max_len, "request_id": request_id}
        logging.info(f'invoke faas-test-1 with {req_data}')
        response = requests.post('http://gateway.openfaas.svc.cluster.local:8080/async-function/faas-test-1', 
                                json=req_data) 
        logging.info(f'code: {(response.status_code)}')
    else:
        # TODO: We should save the result to an external database
        logging.info('reach the destination')

    return 'goodbye faas-test-2'
