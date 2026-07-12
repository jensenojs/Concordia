# Concordia backend组件制品

## 目标

从CNB exact source、仓内Cargo.lock与固定LLVM/Rust/CUDA工具链生成唯一`libnvcuda.so`，发布本仓OCI并在新任务中按digest恢复。该切片为BR2，不运行QEMU或模型。

## 预期结构

```text
concordia/
├── Cargo.lock
├── manifests/
│   ├── build-profile.json
│   ├── artifact-contract.json
│   └── artifacts/concordia.json
├── scripts/
│   ├── AGENTS.md
│   ├── build_component.sh
│   ├── component_artifact.py
│   ├── publish_component.sh
│   └── pull_component.sh
└── tests/test_component_artifact.py
```

payload只含`lib/libnvcuda.so`。系统C/C++运行库由固定consumer环境提供，manifest记录`DT_NEEDED`但不捆绑动态库。

## 输入和调用链

```text
source commit + Cargo.lock + build-profile + toolchain digest
  → cargo build --locked, nvidia only
  → ELF/export检查
  → deterministic component archive + manifest
  → ORAS digest
  → independent fresh pull + repeated checks
```

Cargo.lock SHA256固定为`25af8d8ea6826c1e7a0a98dbe28823cdfa6a3bb1fd83cea0fea9b7aaa94d475b`，与本地成功build和旧控制仓冻结副本逐字节一致。`llvm_zluda`通过path dependency读取`ext/llvm-project/llvm-sys`；build只从gitlink`6c4f4634...`稀疏恢复该目录，LLVM二进制和链接输入仍来自固定系统LLVM21。`ext/cuda-tile@72de6de8...`及完整LLVM源码不参与该profile。

## 验收边界

必须看到`cuInit`、`cuLaunchKernel`、`cuMemcpyDtoHAsync`和`cuModuleGetGlobal_v2`动态导出。fresh pull成功前不提交正式artifact manifest。该结果不证明QEMU实际加载backend、GPU kernel返回、固定1.5B或Kimi。
