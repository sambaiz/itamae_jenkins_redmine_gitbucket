## Use local vagrant (recommend)

```
vagrant init (centos7's box name)
```

Vagrantfile

```
config.vm.network "private_network", ip: "192.168.33.10"
```

```
itamae ssh -h 192.168.33.10 -u vagrant roles/web.rb
vagrant@192.168.33.10's password:vagrant
```

```
rake spec
```


## Use vagrant-aws (unrecommend)

### Config Vagrantfile

```
Vagrant.configure(2) do |config|
  # Box名（vagrant-awsでは使用はしないが指定しなくてはならない）
  config.vm.box = "dummy"

  # 同期するフォルダを選択（vagrant-awsでは常に同期される訳ではなく、provisionやupなどの
  # コマンド実行時に同期される）
  config.vm.synced_folder "./", "/home/centos/vagrant", disabled: true

  config.vm.provider :aws do |aws, override|
    # アクセスキー（リポジトリに入れたいので環境変数に保持）
    # http://docs.aws.amazon.com/ja_jp/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html
    aws.access_key_id     = ENV['AWS_ACCESS_KEY_ID']
    # シークレットアクセスキー（リポジトリに入れたいので環境変数に保持）
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    # キー名
    # http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair
    aws.keypair_name = 'vagrant-aws'
    # インスタンスタイプ（http://aws.amazon.com/jp/ec2/pricing/ を参照）
    aws.instance_type = "t2.micro"
    # リージョン（東京はap-northeast-1）
    aws.region = "ap-northeast-1"
    # アベイラビリティゾーン
    aws.availability_zone =  "ap-northeast-1c"
    # 使用するAMIのID (CentOS 7 (x86_64) with Updates HVM)
    aws.ami = "ami-89634988"
    # セキュリティグループ（複数指定でor判定）
    # http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/using-network-security.html#creating-security-group
    aws.security_groups = ['vagrant-aws']
    # タグ
    aws.tags = {
      'Name' => 'vagrant',
      'Description' => 'vagrant-aws'
    }
    # sudo: sorry, you must have a tty to run sudo 対策
    # config.ssh.pty = true
    # Amazon Linuxの場合は最初からsudoできないので指定しておく
    aws.user_data = "#!/bin/sh\nsed -i 's/^Defaults\\s*requiretty/Defaults !requiretty/' /etc/sudoers\n"
    # EBSの指定が可能
    aws.block_device_mapping = [
      {
        # デバイス名
        'DeviceName' => "/dev/sda1",
        # 名称
        'VirtualName' => "v1",
        # ボリュームサイズ（GB単位）
        'Ebs.VolumeSize' => 10,
        # ターミネートした際に削除するかどうか
        'Ebs.DeleteOnTermination' => true,
        # EBSのタイプを指定
        'Ebs.VolumeType' => 'standard',
        #'Ebs.VolumeType' => 'io1',
        # standardでIOPSを指定するとエラーが発生するので注意
        #'Ebs.Iops' => 1000
      }
    ]
    # -----
    # ここからはVPCを使用する際の設定
    # サブネットID（マネジメントコンソールから取得）
    #aws.subnet_id = 'サブネットID'
    # VPC内のローカルIPアドレスを指定
    #aws.private_id_address = '192.168.0.33'
    # 自動的にEIPを割り当てる場合（EIPの取得上限は5個のためそれ以上の指定はエラーとなる）
    # aws.elastic_ip = true
    # ELBを指定
    # aws.elb = "production-web"

    # -----
    # SSHのユーザー名を指定（Amazon Linuxはec2-user、ubuntuはubuntu、CentOSはcentos）
    override.ssh.username = "centos"
    # SSHのKeyのパスを指定
    override.ssh.private_key_path = "vagrant-aws.pem"
  end

  # 実行するShellScript
  config.vm.provision "shell", inline: <<-SCRIPT
  echo 'Start ShellScript'
  sudo cp -p /usr/share/zoneinfo/Japan /etc/localtime
  echo 'Itamae start'
  cd /vagrant
  sudo yum install -y ruby
  sudo gem install bundler
  sudo sed -i 's/^Defaults\\s*secure_path\\s*=.*/Defaults secure_path = \\/sbin:\\/bin:\\/usr\\/sbin:\\/usr\\/bin:\\/usr\\/local\\/bin/' /etc/sudoers
  sudo bundle install
  sudo itamae local roles/web.rb
  echo 'Itamae done'
  echo 'Severspec start'
  sudo rake spec
  echo 'Severspec done'
  SCRIPT

end
```

の内、以下の要素について設定する必要がある

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
