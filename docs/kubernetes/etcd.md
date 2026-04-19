# etcd

쿠버네티스의 데이터베이스. 클러스터의 모든 선언된 상태를 저장한다.

```
kubectl apply -f kafka.yaml
  → API Server가 검증
  → etcd에 저장 ("Kafka 클러스터가 있어야 한다"는 선언)
```

## 접근 방식

모든 컴포넌트는 etcd에 직접 접근하지 않고 API Server를 통해서만 읽고 쓴다.

```
Controller, kubelet, kube-proxy
  → API Server → etcd
```

## 저장 내용

```
- Pod, Deployment, Service 등 모든 오브젝트
- 노드 정보
- ConfigMap, Secret
```

## etcd 자체

분산 키-값 저장소. 쿠버네티스 외에도 쓸 수 있는 별도 오픈소스 프로젝트이며, 쿠버네티스가 상태 저장소로 채택했다. 고가용성을 위해 보통 3개 또는 5개 노드로 클러스터를 구성한다.
