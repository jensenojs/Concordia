# Concordia组件制品证据

## 失败链

首次构建任务[`cnb-hqg-1jtb33lle`](https://cnb.cool/gevico.online/jensen/concordia/-/build/logs/cnb-hqg-1jtb33lle)在Cargo解析workspace时发现`ext/llvm-project/llvm-sys/Cargo.toml`缺失。系统LLVM只提供二进制和链接输入，不能替代Rust path dependency。

任务[`cnb-g1o-1jtb3g5i3`](https://cnb.cool/gevico.online/jensen/concordia/-/build/logs/cnb-g1o-1jtb3g5i3)在恢复前拒绝了错误的LLVM gitlink OID。源码树确认`ext/llvm-project`固定为`6c4f463494eeda4e19f1c45a5cab8225024da750`；`72de6de8...`属于本次构建不消费的`ext/cuda-tile`。

任务[`cnb-m3g-1jtb3oq6h`](https://cnb.cool/gevico.online/jensen/concordia/-/build/logs/cnb-m3g-1jtb3oq6h)进入Rust编译后发现`llvm-sys`还读取相邻的`cmake/Modules/LLVMVersion.cmake`。最终恢复合同只包含`llvm-sys`和`cmake/Modules`，没有初始化完整LLVM源码。

任务[`cnb-2pg-1jtb4bole`](https://cnb.cool/gevico.online/jensen/concordia/-/build/logs/cnb-2pg-1jtb4bole)继续编译到`llvm_zluda`，随后证明本地Fedora入口使用的`/usr`不是CNB固定工具链的LLVM根目录。云端profile将`LLVM_SYS_211_PREFIX`和`LLVM_ZLUDA_PREBUILT`固定为`/usr/lib/llvm-21`，构建前显式验证`llvm-config`。

## 构建与发布

任务[`cnb-ldg-1jtb4qasj`](https://cnb.cool/gevico.online/jensen/concordia/-/build/logs/cnb-ldg-1jtb4qasj)消费source commit `0f7b55aac64be9bc3bdac10020f2a227913ddb66`和固定toolchain digest `sha256:8732c435c97964f2ba95b42fbbcaf79b3c23feffc3b1f7683531917122f4f59e`。任务以4 CPU、8 GiB运行，使用锁定的Cargo依赖、NVIDIA feature、系统LLVM 21和声明的稀疏gitlink输入完成构建。验证记录包含ELF动态依赖和导出符号，并要求`cuInit`、`cuLaunchKernel`、`cuMemcpyDtoHAsync`与`cuModuleGetGlobal_v2`存在。

发布结果：

```text
repository=docker.cnb.cool/gevico.online/jensen/concordia
digest=sha256:0455178c2b050b31e4e9fa7cf80bfafd9f6fd2fba41f52f869ef7d0782c1d710
archive_sha256=f896b8cf1e2b7a59f33815881b16869d41d7fef97f9bab6e069cc47dc663d5ae
manifest_sha256=faaa06c28ce4e9e352c1f9a3f46aaf5ae852637641b3511735ef8859ec569c16
profile_sha256=8532dbe39777ca2c18eadaa0ab615a4c6bf499d354e13be2aee37131d6b81cf3
```

独立任务[`cnb-00g-1jtb5b599`](https://cnb.cool/gevico.online/jensen/concordia/-/build/logs/cnb-00g-1jtb5b599)以2 CPU、4 GiB运行，只按上述digest恢复制品。它重复执行合同负向测试、双blob hash、安全恢复、ELF动态依赖和导出符号检查，输出`component_fresh_pull=pass`。

## 证明边界

该证据证明`libnvcuda.so`可从固定源码和声明输入构建，并能从新CNB任务按不可变digest恢复。它不证明QEMU能加载该库、NVIDIA设备初始化、真实kernel launch、guest输出、固定1.5B、Kimi或性能；这些事实必须由后续组合运行产生。
