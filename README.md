# 上传图片

所有配置都在 config 文件夹下

当前只支持 macOS, 因为当前的获取剪切板的二进制文件只有 mac 的

## 当前支持类型

- [x] azure

## Azure

`AzureUploader.json`

```json
{
  "org": "cjlspy",
  "project": "images",
  "repo": "images",
  "token": "",
  "user": "cjlspy"
}
```

token 可以是登陆密码, 也可以是 azure 里的`Personal Access Tokens`

登陆情况下的访问地址: https://dev.azure.com/XXX/_usersSettings/tokens

XXX 换成你自己的用户名
