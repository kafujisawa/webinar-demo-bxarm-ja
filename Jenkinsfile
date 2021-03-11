pipeline {
    agent any

    stages {
        stage('Create Docker Image') {
            steps {
                sh '''cp /home/ubuntu/dockerfile/Dockerfile ./
                cp /home/ubuntu/dockerfile/bxarm-8.50.9.deb ./
                docker build -t cpptest:cpptest .'''
            }
        }
        stage('Run Docker Container') {
            steps {
                sh 'docker run --net host --name cpptest_docker --workdir /home/ubuntu -itd -v /home/ubuntu/parasoft:/home/ubuntu/parasoft cpptest:cpptest'
            }
        }
        stage('Clone Project from GitHub') {
            steps {
                sh 'docker exec --user 1000 -i cpptest_docker git clone https://github.com/kafujisawa/webinar-demo-bxarm-ja'
            }
        }
        stage('Build Project') {
            steps {
                sh 'docker exec --user 1000 -i cpptest_docker /bin/bash -c "cd webinar-demo-bxarm-ja && cmake . -DCMAKE_BUILD_TYPE=debug && cmake --build . --config debug"'
            }
        }
        stage('Create C++test Project') {
            steps {
                sh 'docker exec --user 1000 -i cpptest_docker cpptestcli -data workspace -bdf webinar-demo-bxarm-ja/compile_commands.json -localsettings parasoft/cpptest/10.5/ls.properties -showdetails'
            }
        }
        stage('Run Static Analysis') {
            steps {
                sh 'docker exec --user 1000 -i cpptest_docker cpptestcli -data workspace -resource webinar-demo-bxarm-ja -config "builtin://MISRA C 2012" -showdetails'
            }
        }
        stage('Delete Docker Container') {
            steps {
                sh '''docker stop cpptest_docker
                docker rm cpptest_docker'''
            }
        }
        stage('Delete Docker Image') {
            steps {
                sh 'docker rmi cpptest:cpptest'
            }
        }
    }
}
