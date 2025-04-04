# DartScript Project Brief

## 核心目标 (Core Goals)

- 创建一个类似PyScript的框架，让开发者能在浏览器中直接编写和执行Dart代码 (Create
  a PyScript-like framework allowing developers to write and execute Dart code
  directly in the browser)
- 使用WebAssembly技术构建Dart运行时环境 (Use WebAssembly technology to build the
  Dart runtime environment)
- 提供简单的HTML标签集成方式，如`<dart-script>` (Provide simple HTML tag
  integration, like `<dart-script>`)
- 实现Dart代码与DOM的交互能力 (Enable interaction between Dart code and the DOM)

## 功能目标 (Functional Goals)

- 支持Dart语言核心语法和基础功能 (Support core Dart syntax and basic features)
- 提供DOM操作API，允许Dart代码控制网页元素 (Provide DOM manipulation APIs
  allowing Dart code to control web elements)
- 建立基本的包管理和依赖系统 (Establish a basic package management and
  dependency system)
- 开发简单直观的错误处理机制 (Develop a simple and intuitive error handling
  mechanism)

## 用户体验目标 (User Experience Goals)

- 降低Dart在Web开发中的使用门槛 (Lower the barrier to entry for using Dart in
  web development)
- 为学习者提供无需安装的Dart编程环境 (Provide learners with a Dart programming
  environment requiring no installation)
- 为Flutter开发者提供快速Web原型工具 (Offer Flutter developers a rapid web
  prototyping tool)
- 创建交互式代码编辑和执行环境 (Create an interactive code editing and execution
  environment)

## 技术目标 (Technical Goals)

- 优化WASM模块大小和加载性能 (Optimize WASM module size and loading performance)
- 实现高效的JavaScript/WASM通信桥接 (Implement an efficient JavaScript/WASM
  communication bridge)
- 确保跨浏览器兼容性 (Ensure cross-browser compatibility)
- 建立安全沙箱运行环境 (Establish a secure sandboxed execution environment)

These goals will guide the development of DartScript from proof-of-concept to
full implementation.
