# NFT活动平台智能合约

本项目是一个基于以太坊的NFT活动平台智能合约，使用Foundry框架开发。该平台允许创建和管理NFT奖励活动，支持自动化抽奖和NFT分发。

## 项目特点

- **NFT铸造**：支持创建和铸造定制化NFT
- **活动管理**：设置活动时间、参与条件和奖励分配
- **自动抽奖**：集成Chainlink自动化功能，保证抽奖公平性
- **权限控制**：完善的权限管理机制
- **可扩展性**：模块化设计，易于扩展

## 技术栈

- Solidity ^0.8.13
- Foundry
- OpenZeppelin合约
- Chainlink

## 项目结构

```
src/
├── NFTFactory.sol       # 主要NFT工厂合约
├── interfaces/          # 接口定义
├── utils/               # 工具合约
test/
├── NFTFactory.t.sol     # 测试用例
script/
├── Deploy.s.sol         # 部署脚本
```

## 安装与设置

### 前置条件

- 安装[Foundry](https://book.getfoundry.sh/getting-started/installation)

### 安装依赖

```shell
$ forge install
```

## 编译合约

```shell
$ forge build
```

## 运行测试

```shell
$ forge test
```

## 部署合约

在部署之前，请创建`.env`文件并设置以下环境变量：

```
PRIVATE_KEY=your_private_key
RPC_URL=your_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
```

然后运行以下命令进行部署：

```shell
$ source .env
$ make deploy-sepolia
```

或手动部署：

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 使用Makefile

项目包含Makefile以简化操作：

- `make build`: 编译合约
- `make test`: 运行测试
- `make deploy-sepolia`: 部署到Sepolia测试网
- `make verify CONTRACT=<合约地址> NETWORK=sepolia`: 验证合约

## 许可证

MIT
