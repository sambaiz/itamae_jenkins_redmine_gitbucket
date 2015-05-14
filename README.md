# Install GitBucket & Jenkins & Redmine to Local Vagrant

- CentOS Linux release 7.0.1406 (Core)

## Box add

[Vagrantbox.es](http://www.vagrantbox.es/)

```
vagrant box add centos7  https://f0fff3908f081cb6461b407be80daf97f07ac418.googledrive.com/host/0BwtuV7VyVTSkUG1PM3pCeDJ4dVE/centos7.box
vagrant init centos7
```

## Edit Vagrantfile

```
config.vm.network "private_network", ip: "192.168.33.10"
config.vm.provider "virtualbox" do |vb|
  vb.memory = "2048"
end
```

## Run itamae

- Install & Configure
    - firewalld
    - Apache (+ Open port 80)
    - Tomcat
    - MariaDB
    - GitBucket (+ Git & Gitbucket plugin)
    - Jenkins
    - Redmine (+ passenger, redmine_github_hook plugin)

- タイミングが悪いとJenkinsのプラグイン入れるところで失敗するので、その場合はもう一回実行する

```
itamae ssh -h 192.168.33.10 -u vagrant roles/web.rb
```

- [http://192.168.33.10/jenkins](http://192.168.33.10/jenkins)
- [http://192.168.33.10/gitbucket](http://192.168.33.10/gitbucket)
- [http://192.168.33.10/redmine](http://192.168.33.10/redmine)

## 連携

- リポジトリの名前をtestRepとする

### Gitbucket

- Username, passwordはroot
- リポジトリ(e.g. testRep)を作ってSettings->Service Hooksに以下のURLを入力してAdd

```
http://localhost/jenkins/gitbucket-webhook/
```

### Jenkins

- タスクを作って以下のようにURLを設定

```
Repository URL: http://192.168.33.10/gitbucket/git/root/testRep.git
リポジトリブラウザ: GitBucket
URL: http://192.168.33.10/gitbucket/
```

### Redmine

- ログイン, パスワードはadmin
- --bareリポジトリはワーキングディレクトリを持たず、更新情報だけを持っている
- 実行ユーザ(nobody?)がリポジトリを読み書きできなければいけない

```
sudo mkdir /var/lib/redmine/repo
sudo chmod a+rw /var/lib/redmine/repo
cd /var/lib/redmine/repo
git clone --bare http://192.168.33.10/gitbucket/git/root/testRep.git
chmod -R a+rw testRep.git
```

- プロジェクトを作ってリポジトリの設定のパスに/var/lib/redmine/repo/testRep.gitを指定
- GitBucketのService Hooksに以下のURLを入力してAdd

```
http://localhost/redmine/github_hook?project_id=(project identifier)
```
