# Container Runtime

컨테이너 이미지를 읽어서 실제 프로세스로 실행하는 프로그램.

```
컨테이너 이미지 (설계도)
       ↓
컨테이너 런타임
       ↓
실행 중인 컨테이너
```

OS 커널 기능(namespace, cgroup)을 써서 격리된 프로세스를 만든다.

## containerd

쿠버네티스에서 가장 많이 쓰는 런타임. Docker도 내부적으로 containerd를 사용한다.

```
Docker
  └── containerd  ← 실제 컨테이너 실행
        └── runc
```

쿠버네티스 1.24부터 Docker 직접 지원을 제거하고 containerd를 직접 사용한다.

```
기존: kubectl → dockershim → Docker → containerd → 컨테이너
현재: kubectl → containerd → 컨테이너
```

중간 레이어가 줄어서 더 가볍고 빠르다.

## Docker 이미지 호환성

이미지 포맷이 OCI(Open Container Initiative) 표준이라 Docker로 빌드한 이미지를 containerd에서 그대로 실행할 수 있다.

```
docker build → OCI 이미지 → Docker Hub 푸시
                                ↓
                     containerd가 pull해서 실행
```

Docker는 이미지 빌드 도구, containerd는 실행 도구. 포맷이 표준화되어 있어서 누가 빌드했든 상관없다.
