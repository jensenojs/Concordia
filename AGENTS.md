# Project: Concordia

本仓保存Concordia/ZLUDA CUDA Driver API兼容层、NVIDIA backend、PTX/CUBIN处理和教程Kimi benchmark入口。它负责host侧`libnvcuda.so`及Type-2 backend计算语义；不拥有QEMU设备模型、guest kernel、CXLMemSim server、模型文件或跨组件run specification。

项目目标、正确性层级与当前工程入口由`/home/jensen/Projects/cxl-memsim/AGENTS.md`定义。CNB独立checkout从`gevico.online/jensen/cxl-lab`有效控制ref `refs/heads/fixed-1p5b-control`读取exact source lock。本机活跃云端组件checkout是`/home/jensen/Projects/cxl-cloud/concordia/`；`/home/jensen/Projects/cxl-memsim/Concordia/`保留既有本地实验现场。

## Cloud Source Authority

在`cxl-lab` source lock切换前，CNB `gevico.online/jensen/concordia`只是candidate，GitHub `jensenojs/Concordia`仍是primary。固定Type-2功能基线是公开branch `type2-fixed-1p5b`上的`e680a2ecc9cf10a06e664c5b599e23b72582d24b`。旧本地checkout虽然branch名显示`tmatmul`，其HEAD不能反向改写公开`tmatmul` ref。

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

`--no-default-features`用于排除`zluda`默认`intel`feature；`nvidia`路径仍通过`comgr`/`ptx`触及`ze_runtime_sys`构建，因此固定工具环境必须提供Level Zero loader，不能依赖缺失的`ext/ze_runtime-sys/src/runner/ze_stub.c` fallback。遗漏`LLVM_ZLUDA_PREBUILT=/usr`或在workspace根泛化构建会重新进入未冻结依赖路径。

`manifests/build-profile.json`只保存这条候选构建形状。首次CNB build、测试和artifact fresh pull通过前，不称为已验证构建身份或正式制品。

## Correctness Boundary

host preload baseline、guest BAR2 shim和Concordia backend是三条不同路径。`libnvcuda.so`成功加载只证明动态链接；backend初始化只证明驱动入口；只有相同输入下的输出或token hash一致才能证明语义。

Kimi benchmark脚本的`status=pass`只表示runner退出0并解析到tokens/tps，不自动比较baseline/concordia输出。正式correctness必须固定seed、采样、model、prompt、ctx、n_predict、offload、VM和GPU，并比较规范化输出。

## Commands

- source probe: `bash scripts/verify_source_checkout.sh e680a2ecc9cf10a06e664c5b599e23b72582d24b`
- validated local build: `LLVM_SYS_211_PREFIX=/usr LLVM_ZLUDA_PREBUILT=/usr CARGO_BUILD_JOBS=1 MAKEFLAGS=-j1 CARGO_INCREMENTAL=0 cargo build -p zluda --features nvidia --no-default-features -j1`
- inspect feature graph: `cargo tree -p zluda --no-default-features --features nvidia -i ze_runtime_sys`

完整Rust/LLVM/CUDA build应在CNB exact SHA和固定toolchain digest上执行。本机实验现场不得成为云端artifact输入。

## Boundaries

- `target/`、AOF、runner日志、模型文件和benchmark CSV/JSONL是生成状态或外部输入，不提交到组件源码历史。
- `ext/llvm-project`和`ext/cuda-tile`是gitlink；source迁移不初始化它们。
- 本仓不复制QEMU、CXLMemSim、kernel、llama或guest的build profile。
- 新CNB任务必须记录repo、branch、exact SHA、event、runner资源、toolchain digest、feature集合、stage和首个失败日志。
