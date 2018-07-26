# NAVER-CAMPUS-HACKDAY / iOS Gesture Player

### 주제 선정 배경
유투브, 넷플릭스, 스노우 바야흐로 미디어 서비스 시대가 열림
구글, 페이스북, 네이버등 글로벌 회사들은 점점 다양한 미디어 컨텐츠 서비스를 제공
미디어 컨텐츠 서비스에서 동영상 재생은 필수 영역이 되어버림
iOS 미디어 프로그래밍을 통해 앞으로 본인의 가능성을 알려줄수 있는 좋은 기회

### 요구사항(필수)
비디오 리스트뷰 
 - 비디오 리스트 제공 (컬렉션뷰)
 - 비디오 리스트는 네트워크를 통해서 받는다. (URLSession, 또는 Alamofire)
 - 비디오 클릭시 바로 플레이어 재생

플레이어 (가로모드만 제공)
 - 재생(버튼) / 정지(버튼) 
 - Seeking(슬라이더) / 10초전(버튼) 
 - 제스쳐 
   - 탭: 탭할때 마다 컨트롤뷰 토글 
   - 더블 탭: 영상 확대 및 원본 비율 토글 
   - 좌우 팬:  Seeking 
   - 좌측 상하: 화면 밝기
   - 우측 상하: 볼륨 조절 
 - 컨트롤뷰 잠금 

### 요구사항(선택)
플레이어 
 - 메뉴(dummy 데이터로 표시)
   - 화질정보 (고화질, 일반화질, 저화질)
   - 자막정보 (한국어, 영어, 자막끄기)

### 개발언어
Swift(선호) / Objective-C

### 플랫폼
iOS(min 10.0)

### 기타 사항
플레이어에 사용할 동영상은 제공
필요한 UI 오픈소스 사용
개발 오픈소스는 사용하지 않는 것을 원칙으로 함(단, 네트워크시 Alamofire만 허용)

------

### 참고 자료

- #### observer

https://developer.apple.com/videos/play/wwdc2017/212/?time=1215

- #### AVPlayerLayer

https://developer.apple.com/documentation/avfoundation/avplayerlayer

- #### Cocoa Event Handling Guide

https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/EventOverview/Introduction/Introduction.html

- #### 봐야할 것

  - 참고 사이트 : https://www.objc.io, https://medium.com 
  - **git flow**
    - https://danielkummer.github.io/git-flow-cheatsheet/index.ko_KR.html
    - http://woowabros.github.io/experience/2017/10/30/baemin-mobile-git-branch-strategy.html


- #### Error

https://stackoverflow.com/questions/46352735/what-is-tic-read-status-157-in-ios11-xcode-9

`TIC Read Status [1:0x0]: 1:57`

TIC : "TCP I/O Connection"

1:  **CFStreamError domain**. `kCFStreamErrorDomainPOSIX`

57 :  **CFStreamError code**. ENOTCONN

즉, ENOTCONN으로 TCP 읽기가 실패한 것이다.

TCP I/O 연결 subsystem은 공개 API가 없기 때문에, High-Level Wrapper(ex. NSURLSession)를 사용해야한다.
