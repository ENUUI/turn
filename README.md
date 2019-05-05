# TURN

Route mediator for flutter.

- 参考: [fluro](https://github.com/theyakka/fluro)。
## Getting started
```
dependencies:
turn:
    git: https://github.com/ENUUI/turn.git
```
目前没有发布到 `pub`（使用一段时间，完善稳定后会发布到`pub`）。


---
## Mediator
是为了解决各`package`之间通信的方案。目前只支持获取 `widget`。
- *Target*：接收处理事件与参数。`packages`应当有各自继承自 `Target`的事件接收者。
- *Mediator*：注册`Target`。并在`perform(String action, {Map<String, dynamic> params})`时解析`action`，查找到对应的`Target`，并将事件与参数转发给`Target`。

#### Action 
1. 格式
   1. `'/'`: 保留给root page;
   2. `'/<TargetName>/<more...>'`: Mediator会将<TargetName>与Target中的Getter TargetName进行匹配，以确定事件接收者。*`（'/<TargetName>/<more...>'与'<TargetName>/<more...>'等价）`*。
2. `action` 在 `Turn` 中可当做 `route path`。
  
###

---
## Turn
###  Navigating
```
Turn.to(
    context, 
    '/<TargetName>/<more...>',  
    params: {"title": "page A"}, // 需要传递给 Target 的参数。
    transition:  TransitionType.fadeIn,
);
```
- 可将 `Mediator` 中的`action`当做`route path`，当要确保` Target` 返回的是一个`Widget`。
- 当`action`必须有对应的`Target`注册到了`Mediator`。

## Example
下载`zip` 或 `clone`到本地，查看`turn/example`。

---

### MIT license
