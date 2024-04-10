# Terraform for Google Cloud Platform
CSYE 6225:  Network Structure & Cloud Computing (Spring 2024) - Prof. Tejas Parikh


### Active GCP services
| Sr no | Service                                 | Status   | When          |
|:------|:----------------------------------------|:---------|:--------------|
| 1.    | Compute Engine API                      | Active   | Assignment 3  |
| 2.    | Service Networking API                  | Active   | Assignment 5  |
| 3.    | Cloud DNS API                           | Active   | Assignment 6  |
| 4.    | Cloud Monitoring API                    | Active   | Assignment 6  |
| 5.    | Cloud Logging API                       | Active   | Assignment 6  |
| 6.    | Cloud Build API                         | Active   | Assignment 7  |
| 7.    | Cloud Functions API                     | Active   | Assignment 7  |
| 8.    | Cloud Pub/Sub API                       | Active   | Assignment 7  |
| 9.    | Eventarc API                            | Active   | Assignment 7  |
| 10.   | Cloud Run Admin API                     | Active   | Assignment 7  |
| 11.   | Cloud Key Management Service (KMS) API  | Active   | Assignment 9  |

#### DB conn from webapp instance
```
sudo dnf module enable postgresql:16 -y
sudo dnf install postgresql-server -y
```

```
psql -h 10.208.0.2 -U webapp_user-mm6008
```


### Check app log
```
cat /var/log/webapp/webapp.log
```
### Check ops agent status
```
sudo systemctl status  google-cloud-ops-agent"*"
```

