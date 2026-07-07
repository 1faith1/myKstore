// ======= 用户配置区 START =======
// 新追加的直连地址,开启规则后下面的所有都走本地直连，不用梯子进行访问
const NEW_RULES = [
  "DOMAIN-SUFFIX,bing.com,DIRECT",
  "DOMAIN-SUFFIX,csdn.net,DIRECT",
  "DOMAIN-SUFFIX,xdgame.com,DIRECT",
  "DOMAIN-SUFFIX,steamstatic.com,DIRECT",
  "DOMAIN-SUFFIX,store.cdn.queniuqe.com,DIRECT",
  "DOMAIN-SUFFIX,steamserver.net,DIRECT",
  "IP-CIDR,154.44.20.0/24,DIRECT",
];

const PROXY_GROUPS = [
  // === 单/多区域组合 - 分组创建 示例 - 自动进行延迟测试
  // 使用此模式match对应地址进行模糊搜索，即使没有也不影响使用
  {
    name: "【日本-自动更新】",
    match: /(日本)/,
	//  === 添加自动测速功能 START ===
	interval: 3600, // 1小时测速一次
	type: "url-test",
    url: "http://www.gstatic.com/generate_204",
	//  === 添加自动测速功能 END ===
  },
  {
    name: "【美泰德-自动更新】",
    match: /(美国|泰国|德国)/,
	// 添加自动测速功能
	interval: 6, // 6秒测速一次
	type: "url-test",
    url: "http://www.gstatic.com/generate_204",
  },
  {
    name: "【新加坡-自动更新】",
    match: /(新加坡)/,
	// 添加自动测速功能
	interval: 6, // 6秒测速一次
	type: "url-test",
    url: "http://www.gstatic.com/generate_204",
  },
  {
    name: "【台湾-自动更新】",
    match: /(台湾)/,
	// 添加自动测速功能
	interval: 6, // 6秒测速一次
	type: "url-test",
    url: "http://www.gstatic.com/generate_204",
  },  
  {
    name: "【香港-自动更新】",
    match: /(香港)/,
	// 添加自动测速功能
	interval: 6, // 6秒测速一次
	type: "url-test",
    url: "http://www.gstatic.com/generate_204",
  }, 	
];
// ======= 用户配置区 END =======





// ============== 核心逻辑 ==============
const main = (config) => {
  console.log("🚀 FIClash 脚本开始执行");

  // 确保关键字段存在
  config.proxies ??= [];
  config["proxy-groups"] ??= [];
  config.rules ??= [];

  const allProxyNames = config.proxies.map(p => p.name);
  const groups = config["proxy-groups"];
  
  // ============ 处理规则 ============
  const rules = config.rules;
  const upperRules = rules.map(r => r.toUpperCase().trim());

  // // 插入点：第一个 MATCH / FINAL(会在最后面添加，如果默认规则中涵盖新添加的规则会不生效)
  // let insertIndex = rules.findIndex(r => {
  //   const u = r.toUpperCase();
  //   return u.startsWith("MATCH") || u.startsWith("FINAL");
  // });
  // if (insertIndex === -1) insertIndex = rules.length;
  
  // 插入点：在rules:下的第一行进行插入
  let insertIndex = 0
  
  let addedCount = 0;
  for (const rule of NEW_RULES) {
    const upper = rule.toUpperCase().trim();
    if (!upperRules.includes(upper)) {
      rules.splice(insertIndex, 0, rule);
      insertIndex++;
      addedCount++;
    }
  }

  if (addedCount > 0) {
    console.log(`✅ 添加规则 ${addedCount} 条`);
  } else {
    console.log("⚠️ 无需添加规则（均已存在）");
  }
  // ============ 处理自定义分组 ============
  // ========== 自动获取proxy-groups第一个分组 ==========
  const firstGroup = groups[0];
  // 兜底，防止第一个分组没有proxies数组
  if (firstGroup && !Array.isArray(firstGroup.proxies)) {
    firstGroup.proxies = [];
  }

  // 存放本次新创建的分组名称
  const newGroupNames = [];

  // 循环创建自定义分组
  for (const groupDef of PROXY_GROUPS) {
    let proxies = [];

    if (groupDef.proxies && Array.isArray(groupDef.proxies)) {
      proxies = groupDef.proxies;
    } else if (groupDef.match instanceof RegExp) {
      proxies = allProxyNames.filter(name => groupDef.match.test(name));
    }

    if (proxies.length === 0) {
      console.log(`⚠️ 代理组 [${groupDef.name}] 未匹配到任何节点`);
      continue;
    }
    // 组装分组基础结构
    const newGroup = {
      name: groupDef.name,
      type: groupDef.type || "select",
      proxies,
    };
    // url-test / fallback 附加 interval、url
    if (["url-test", "fallback"].includes(newGroup.type)) {
      if (typeof groupDef.interval === "number") {
        newGroup.interval = groupDef.interval;
      }
      if (typeof groupDef.url === "string") {
        newGroup.url = groupDef.url;
      }
    }
    // 去重新建分组
    const exists = groups.some(g => g.name === newGroup.name);
    if (!exists) {
      groups.push(newGroup);
      newGroupNames.push(newGroup.name);
      console.log(`✅ 添加代理组：${newGroup.name}（${proxies.length} 节点）type:${newGroup.type}`);
    } else {
      console.log(`⚠️ 已存在代理组：${newGroup.name}`);
    }
  }
  // 将本次新建分组名追加到【第一个分组】内部proxies，自动去重
  if (firstGroup && newGroupNames.length > 0) {
    for (const gName of newGroupNames) {
      if (!firstGroup.proxies.includes(gName)) {
        firstGroup.proxies.push(gName);
      }
    }
    console.log(`✅ 已将新增分组添加至proxy-groups第一个分组「${firstGroup.name}」列表末尾`);
  } else if (!firstGroup) {
    console.log("⚠️ proxy-groups 暂无任何分组，跳过追加操作");
  }
  // ============ END ============
  console.log("🎉 FIClash 配置更新完成");
  return config;
};
