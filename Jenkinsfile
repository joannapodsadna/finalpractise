node {
  def acr = 'acrdemo5.azurecr.io'
  def appName = 'whoami'
  def imageName = "${acr}/${appName}"
  def imageTag = "${imageName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
  def appRepo = "acrdemo5.azurecr.io/whoami:v.0.1.0"

  checkout scm
  
 stage('Build the Image and Push to Azure Container Registry') 
 {
   app = docker.build("${imageName}")
   withDockerRegistry([credentialsId: 'kama-kama', url: "https://${acr}"]) {
      app.push("${env.BRANCH_NAME}.${env.BUILD_NUMBER}")
                }
  }

 stage ("Deploy Application on Azure Kubernetes Service")
 {
  switch (env.BRANCH_NAME) {
    // Roll out to canary environment
    
    case "master":
        // Change deployed image in master to the one we just built
        sh("sudo kubectl --kubeconfig ~jenkinsdemo5/.kube/configkubectl get ns prod || sudo kubectl --kubeconfig ~jenkinsdemo5/.kube/configkubectl create ns prod")
        withCredentials([usernamePassword(credentialsId: 'kama-kama', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "sudo kubectl --kubeconfig ~jenkinsdemo5/.kube/config -n prod get secret kama-kama || kubectl --namespace=prod create secret docker-registry kama-kama --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        } 
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/production/*.yaml")
        sh("sudo kubectl --kubeconfig ~jenkinsdemo5/.kube/config --namespace=prod apply -f k8s/production/")
        sh("echo http://`sudo kubectl --kubeconfig ~jenkinsdemo5/.kube/config --namespace=prod get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break

    case "canary":
        // Change deployed image in canary to the one we just built
        sh("kubectl get ns prod || kubectl create ns prod")
        withCredentials([usernamePassword(credentialsId: 'kama-kama', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "kubectl -n prod get secret mysecret || kubectl --namespace=prodcreate secret docker-registry mysecret --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/canary/*.yaml")
        sh("sudo kubectl --kubeconfig ~jenkinsdemo5/.kube/config --namespace=prod apply -f k8s/canary/")
        sh("echo http://`sudo kubectl -kubeconfig ~jenkinsdemo5/.kube/config --namespace=prod get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break

  case "stage":
        // Change deployed image in canary to the one we just built
        sh("kubectl get ns stage || kubectl create ns stage")
        withCredentials([usernamePassword(credentialsId: 'kama-kama', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "kubectl -n stage get secret mysecret || kubectl --namespace=stage create secret docker-registry mysecret --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/stage/*.yaml")
        sh("sudo kubectl --kubeconfig ~jenkinsdemo5/.kube/config --namespace=stage apply -f k8s/stage/")
        sh("echo http://`sudo kubectl -kubeconfig ~jenkinsdemo5/.kube/config --namespace=stage get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break

    // Roll out a dev environment
    case "dev":
        // Create namespace if it doesn't exist
        sh("kubectl get ns dev || kubectl create ns dev")
        withCredentials([usernamePassword(credentialsId: 'kama-kama', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "kubectl -n dev get secret mysecret || kubectl --namespace=dev create secret docker-registry mysecret --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }
        sh("sudo kubectl --kubeconfig ~jenkinsdemo5/.kube/config get ns dev || sudo kubectl --kubeconfig ~joanna/.kube/config create ns ${appName}-${env.BRANCH_NAME}")
        // Don't use public load balancing for development branches
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/dev/*.yaml")
        sh("sudo kubectl --kubeconfig ~jenkinsdemo5/.kube/config --namespace=dev apply -f k8s/dev/")
        echo 'To access your environment run `kubectl proxy`'
        echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${appName}-${env.BRANCH_NAME}/services/${appName}:80"     
    }
  }
}
