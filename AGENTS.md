# Project: Concordia

本仓保存Concordia/ZLUDA CUDA Driver API兼容层、NVIDIA backend、PTX/CUBIN处理和教程Kimi benchmark入口。它负责host侧`libnvcuda.so`及Type-2 backend计算语义；不拥有QEMU设备模型、guest kernel、CXLMemSim server、模型文件或跨组件run specification。

项目目标、正确性层级与实时工程入口由`/home/jensen/Projects/cxl-memsim/AGENTS.md`定义。跨组件exact source从`cxl-lab/manifests/sources.lock.json`读取。本机活跃云端组件checkout是`/home/jensen/Projects/cxl-cloud/concordia/`；`/home/jensen/Projects/cxl-memsim/Concordia/`保留既有本地实验现场。

## Cloud Source Authority

CNB `gevico.online/jensen/concordia`是源码与本仓制品primary，GitHub `jensenojs/Concordia`保存相同SHA公开镜像。branch用于开发发现，source lock中的exact commit才是跨组件运行输入；旧本地checkout不能反向定义公开ref或云端artifact。

source迁移只证明公开heads/tags及其可达superproject对象，不证明两个gitlink、Rust build、NVIDIA backend、Type-2或Kimi。局部边界见`docs/specs/cloud-source-authority.md`，执行证据见`docs/evidence/cloud-source-migration.md`。

## Cloud Build Boundary

当前已验证本地入口是：

```text
LLVM_SYS_211_PREFIX=/usr
LLVM_ZLUDA_PREBUILT=/usr
CARGO_BUILD_JOBS=1
MAKEFLAGS=-j1
CARGO_INCREMENTAL=0
cargo build -p zluda --features nvidia --no-default-features -j1
```

固定CNB工具链把LLVM21安装在`/usr/lib/llvm-21`。`manifests/build-profile.json`中的CNB构建环境必须同时使用`LLVM_SYS_211_PREFIX=/usr/lib/llvm-21`和`LLVM_ZLUDA_PREBUILT=/usr/lib/llvm-21`；build脚本在进入Cargo前验证`bin/llvm-config`。本地`/usr`路径只描述旧实验现场，不能复制为CNB构建输入。

`--no-default-features`用于排除`zluda`默认`intel`feature；`nvidia`路径仍通过`comgr`/`ptx`触及`ze_runtime_sys`构建，因此固定工具环境必须提供Level Zero loader，不能依赖缺失的`ext/ze_runtime-sys/src/runner/ze_stub.c` fallback。遗漏`LLVM_ZLUDA_PREBUILT`或在workspace根泛化构建会重新进入未冻结依赖路径。

`manifests/build-profile.json`是CNB构建输入权威；正式引用位于`manifests/artifacts/concordia.json`，任务、失败链和证明边界位于`docs/evidence/cloud-component-artifact.md`。本文件不复制完成任务或digest。

## Correctness Boundary

host preload baseline、guest BAR2 shim和Concordia backend是三条不同路径。`libnvcuda.so`成功加载只证明动态链接；backend初始化只证明驱动入口；只有相同输入下的输出或token hash一致才能证明语义。

Kimi benchmark脚本的`status=pass`只表示runner退出0并解析到tokens/tps，不自动比较baseline/concordia输出。正式correctness必须固定seed、采样、model、prompt、ctx、n_predict、offload、VM和GPU，并比较规范化输出。

## Commands

- source probe: `bash scripts/verify_source_checkout.sh <expected-source-sha>`
- validated local build: `LLVM_SYS_211_PREFIX=/usr LLVM_ZLUDA_PREBUILT=/usr CARGO_BUILD_JOBS=1 MAKEFLAGS=-j1 CARGO_INCREMENTAL=0 cargo build -p zluda --features nvidia --no-default-features -j1`
- inspect feature graph: `cargo tree -p zluda --no-default-features --features nvidia -i ze_runtime_sys`

完整Rust/LLVM/CUDA build应在CNB exact SHA和固定toolchain digest上执行。本机实验现场不得成为云端artifact输入。

## Boundaries

- `target/`、AOF、runner日志、模型文件和benchmark CSV/JSONL是生成状态或外部输入，不提交到组件源码历史。
- `ext/llvm-project`和`ext/cuda-tile`是gitlink；source迁移不初始化它们。组件build只按profile恢复`ext/llvm-project/llvm-sys`与其读取的`ext/llvm-project/cmake/Modules`；完整LLVM源码和cuda-tile仍不进入当前build。
- 本仓不复制QEMU、CXLMemSim、kernel、llama或guest的build profile。
- 新CNB任务必须记录repo、branch、exact SHA、event、runner资源、toolchain digest、feature集合、stage和首个失败日志。
