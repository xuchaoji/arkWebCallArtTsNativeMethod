import { webview } from '@kit.ArkWeb';
import deviceInfo from '@ohos.deviceInfo';
import { prompt, promptAction, router } from '@kit.ArkUI';

interface GeneratedObjectLiteralInterface_1 {
  model: string;
  osVersion: string;
}

const TAG: string = 'MyDemoIndex'

const JS_NAME: string = 'JSBridgeName';

@Entry
@ComponentV2
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();
  jsBridge: JSBridge = new JSBridge();

  aboutToDisappear(): void {
    try {
      this.controller.deleteJavaScriptRegister(JS_NAME);
    } catch (e) {
      console.error(TAG, `delete js register error`)
    }
  }

  build() {
    Column() {
      // WebView组件
      Web({
        src: $rawfile('jsPage.html'),
        controller: this.controller
      })
        .onControllerAttached(() => {
          this.controller.registerJavaScriptProxy(
            this.jsBridge,
            JS_NAME, // H5页面调用时使用 具体见：jsPage.html中的callJSBridge()
            ['onMessage', 'showToast', 'showDialog', 'getDeviceInfo', 'goBack'] // 支持的方法列表
          );
          this.controller.refresh();
        })
        .onPageEnd(e => {
          console.log(TAG, '页面加载完成');
        })
        .onAttach(() => {
          setTimeout(() => {
            this.controller.refresh();
          }, 1000)
        })
        .javaScriptAccess(true)
        .fileAccess(true)
        .domStorageAccess(true)
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }

}

// 可扩展的JSBridge类
class JSBridge {
  // 通用消息处理器
  onMessage(message: string) {
    console.log(TAG, `收到H5消息: ${message}`);
    try {
      const msg:string = JSON.parse(message);
      // 处理自定义消息
      return '消息已接收';
    } catch (e) {
      console.error(TAG, '消息解析错误:', e);
      return '消息格式错误';
    }
  }

  // 显示Toast
  showToast(message: string) {
    console.log(TAG, `call showToast`)
    promptAction.showToast({ message: message, duration: 2000 });
    return `Toast显示: ${message}`;
  }

  // 显示对话框
  showDialog(title: string, message: string) {
    console.log(TAG, `call showDialog`)
    promptAction.showDialog({
      title: title,
      message: message
    });
    return `call success`;
  }

  // 返回上一页
  goBack() {
    console.log(TAG, `call goBack`)
    router.back();
    return '返回操作执行';
  }

  // 获取设备信息
  getDeviceInfo() {
    console.log(TAG, `call getDeviceInfo`)
    const deviceInfos: GeneratedObjectLiteralInterface_1 = {
      model: deviceInfo.productModel,
      osVersion: deviceInfo.osFullName
    };
    return JSON.stringify(deviceInfos);
  }
}