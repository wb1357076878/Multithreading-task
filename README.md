# Multithreading-task
### 前言
学习Swift语言已有一段时间了，深深地被其语言的简洁美所打动！最近写了个关于Swift多线程开发的Demo。费话不多说直接代码撸起来^_^
###  正文
#### 1. 使用storyboard快速开发
大家可以看下， 我使用了SplitViewController，这是因为它的Master和details试图非常强大。使用起来很方便！
![Main.storyboard.png](http://upload-images.jianshu.io/upload_images/9239494-eff53ae29feb13e4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### 2. 下面是我们的master
```
import UIKit

class CassiniViewController: UIViewController
{

// MARK: - Navigation

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
if let url = DemoURL.NASA[segue.identifier ?? ""] {
if let imageVC = (segue.destination.contents as? ImageViewController) {
imageVC.imageURL = url
imageVC.title = (sender as? UIButton)?.currentTitle
}
}
}

}

extension UIViewController {
var contents: UIViewController {
if let navcon = self as? UINavigationController {
return navcon.visibleViewController ?? self
} else {
return self
}
}
}
```
#### 3. 下面是我们的details
```
import UIKit

class ImageViewController: UIViewController
{
var imageURL: URL? {
didSet {
image = nil
if view.window != nil { // 如果view是在Screen上的话，才去fetchImage()
fetchImage()
}
}
}
// 这部操作是耗时的
private func fetchImage() {
if let url = imageURL {
let urlContents = try? Data(contentsOf: url)
if let imageData = urlContents {
image = UIImage(data: imageData)
}
}
}

override func viewWillAppear(_ animated: Bool) {
super.viewWillAppear(animated)
if image == nil {
fetchImage()
}
}

@IBOutlet weak var scrollView: UIScrollView! {
didSet {
scrollView.delegate = self
scrollView.minimumZoomScale = 0.03
scrollView.maximumZoomScale = 1.0
scrollView.contentSize = imageView.frame.size
scrollView.addSubview(imageView)
}
}

fileprivate var imageView = UIImageView()

private var image: UIImage? {
get {
return imageView.image
}
set {
imageView.image = newValue
imageView.sizeToFit()
scrollView?.contentSize = imageView.frame.size
}
}
}

extension ImageViewController: UIScrollViewDelegate {
func viewForZooming(in scrollView: UIScrollView) -> UIView? {
return imageView
}
}
```
#### 4. URL
这里我利用swift的结构体封装URL
```
import Foundation

struct DemoURL {
static let stanford = URL(string: "https://www-media.stanford.edu/wp-content/uploads/2017/03/24182714/about_landing-1.jpg")

static var NASA: Dictionary<String,URL> = {
let NASAURLStrings = [
"Cassini" : "http://www.nasachina.cn/wp-content/uploads/2017/09/LastRingPortrait_Cassini_1080.jpg",
"Earth" : "http://www.nasachina.cn/wp-content/uploads/2017/09/ega_1ms_mapcam_color_corrected_0.png",
"Saturn" : "http://www.nasachina.cn/wp-content/uploads/2017/10/pia21352-1041.jpg"
]
var urls = Dictionary<String,URL>()
for (key,value) in NASAURLStrings {
urls[key] = URL(string: value)
}
return urls
}()
}
```
最后源代码[地址](https://github.com/wb1357076878/Multithreading-task)

