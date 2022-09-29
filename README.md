## HTTPClient

A HTTP Client for iOS using Alamofire.

### Usage

#### Config Client

```swift
extension HTTPClient {
  var defaultHttpHeaders: HTTPHeaders {
    var headers = HTTPHeaders([])
    if let token = UserInfoManager.token {
      headers.add(name: "Authori-zation", value: token)
    }
    return headers
  }

  var defaultParameters: Parameters { return [:] }
  var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
  
  // {"code": 0, "message": "SUCCESS", "data": {}}
  var decodePath: String? {
    return "data"
  }
}
```

#### Define your own client

```swift
struct APIManager: HTTPClient {
  var baseURL: URL {
    return URL(string: "https://xxxxx/")!
  }
}
```

#### Create your request

```swift
struct YourRequest {
  
}

extension YourRequest: HTTPRequest {
  typealias DecodableType = YourModel
  
  var path: String { "web/home/list" }
  
  var parameterEncoding: ParameterEncoding? { URLEncoding.default }
  
  var parameters: Parameters? {
    ["userId": "xxx"]
  }
}
```

#### Start your request

```swift
let request1 = YourRequest()
let request2 = YourRequest()

async let response1 = APIManager().send(request1)
  .serializingParsable(of: YourModel.self)
  .response

async let response2 = APIManager().send(request2)
  .serializingParsable(of: YourModel.self)
  .response

let responses = await [response1, response2]
```

### Installation

- **Using Swift Package Manager**

  ```swift
  import PackageDescription

  let package = Package(
    name: "MyAwesomeApp",
    dependencies: [
      .package(url: "https://github.com/douking/HTTPClient", from: "0.1.0"),
    ]
  )
  ```

### LICENES

See LICENES file for more infomation.