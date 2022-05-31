


#### 1 初始化TurnTo

```
 class SomeTurnTo extends TurnTo {
 }
 
 TurnTo turnTo = SomeTurnTo(); 
```
或者
```
 TurnTo turnTo = TurnTo.base(); 
```

#### 2 初始化package 

至少需要一个package。可以有多个package。  
`TurnTo`与`Package`都继承自`Navigateable`。  
在不指定package时，跳转查询到的第一个路由；当指定package时，优先跳转指定package路由。


```
class MainPackage extends Package {
    String get package => 'main';
}

turnTo.registerPackage(MainPackage());
```

#### 3 开启 TurnTo

```
turnTo.fire();
```
