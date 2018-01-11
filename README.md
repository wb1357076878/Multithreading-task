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
#### 5. GCD(Multithreading)
>实际上不用特意生成Dispatch Queue系统也会给我们提供几个。那就是Main Dispatch Queue和Global Dispatch Queue。
>Main Dispatch Queue正如其名称中含有的“Main”一样，是在主线程中执行的Dispatch Queue。因为主线程只有1个，所以Main Dispatch Queue自然就是Serial Dispatch Queue。
>追加到Main Dispatch Queue的处理在主线程的RunLoop中执行。由于在主线程中执行，因此要将用户界面的界面更新等一些必须在主线程中执行的处理追加到Main Dispatch Queue使用。这正好与NSObject类的performSelectorOnMainThread实例方法这一执行方法相同。
>另一个Global Dispatch Queue是所有应用程序都能够使用的Concurrent Dispatch Queue。没有必要通过dispatch_queue_create函数逐个生成Concurrent Dispatch Queue。只要获取Global Dispatch Queue使用即可。
>另外，Global Dispatch Queue有4个执行优先级，分别是高优先级（High Priority）、默认优先级（Default Priority）、低优先级（Low Priority）和后台优化级（Background Priority）。通过XNU内核管理的用于Global Dispatch Queue的线程，将各自使用的Global Dispatch Queue的执行优化级作为线程的执行优先级使用。在向Global Dispatch Queue追加处理时，应选择与处理内容对应的执行优先级的Global Dispatch Queue。
>但是通过XNU内核用于Global Dispatch Queue的线程并不能保证实时性，因此执行优先级只是大致的判断。例如在处理内容的执行可有可无时，保用后台优化级的Global Dispatch Queue等，只能进行这种程序的区分。
```
DispatchQueue.global(qos: .userInitiated).async { [weak weakSelf = self] in
    let urlContents = try? Data(contentsOf: url)
    if let imageData = urlContents, url == weakSelf?.imageURL {
        DispatchQueue.main.async {
            weakSelf?.image = UIImage(data: imageData)
        }
    }
}
```
最后源代码[地址](https://github.com/wb1357076878/Multithreading-task)

