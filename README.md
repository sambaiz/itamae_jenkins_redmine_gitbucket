### Config Vagrantfile

```
# アクセスキー（リポジトリに入れたいので環境変数に保持）
# http://docs.aws.amazon.com/ja_jp/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html
aws.access_key_id     = ENV['AWS_ACCESS_KEY_ID']
# シークレットアクセスキー（リポジトリに入れたいので環境変数に保持）
aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
# キー名
# http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair
aws.keypair_name = 'vagrant-aws'
# セキュリティグループ（複数指定でor判定）
# http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/using-network-security.html#creating-security-group
aws.security_groups = ['vagrant-aws']
# SSHのKeyのパスを指定
override.ssh.private_key_path = "vagrant-aws.pem"
```

### Run spec

```
vagrant up --provision --provider aws
```

or

```
vagrant provision
```

---

```
vagrant destroy
```
