#!/bin/python

import requests
import json
import os
#from requests.auth import HTTPBasicAuth
#auth=HTTPBasicAuth('user', 'pass')


def kGenerate():
    r = requests.post('http://127.0.0.1:9000/api/user_tokens/generate', auth=('admin', 'admin'), data={'name': 'JMXLOCALUSER', 'login': 'admin'})
    #resp_data = json.loads(r.text)
    if r.status_code == 200 :
        file = open( ".sonarsecret" , "w+")
        resp_data = json.loads(r.text)
        file.write(resp_data["token"])
        file.close()
        print "Key succesfully generated and saved"
    else :
        print "User Key generation failed : \n", r.text , r.status_code

#curl -u admin:admin -X POST 'http://localhost:9005/api/projects/create?key=JMXPROJECTKEY&name=JMXProject'

def pCreate():
    sProject = requests.post('http://127.0.0.1:9000/api/projects/create', auth=('admin', 'admin'), data={'name': 'JMXLOCAL', 'key': 'JMXLOCALPROJECTKEY'})
    #resp_data = json.loads(r.text)
    if sProject.status_code == 200 :
        print "Project created : \n", sProject.text , sProject.status_code
    else :
        print "Project creation failed : \n", sProject.text , sProject.status_code


def pStatus():
    payload = {'projectKey': 'THISISFIRSTPROJECT'}
    pStatus = requests.get('http://52.173.78.153:9000/api/qualitygates/project_status', params=payload, auth=('admin', 'admin'))
    #resp_data = json.loads(r.text)
    if pStatus.status_code == 200 :
        print "Project status fetched : \n", pStatus.text , pStatus.status_code
        resp_data = json.loads(pStatus.text)
        file = open( ".sonarstatus" , "w+")        
        file.write(resp_data['projectStatus']['status'])
        file.close()
        print "Status succesfully generated and saved"
        print resp_data
    else :
        print "Project creation failed : \n", pStatus.text , pStatus.status_code






kGenerate()
