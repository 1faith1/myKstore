// ======= 用户配置区 =======
// 新追加的直连地址,开启规则后下面的所有都走本地直连，不用梯子进行访问
const NEW_RULES = [
  "DOMAIN-SUFFIX,bing.com,DIRECT",
  "DOMAIN-SUFFIX,csdn.net,DIRECT",
  "DOMAIN-SUFFIX,xdgame.com,DIRECT",
  "DOMAIN-SUFFIX,steamstatic.com,DIRECT",
  "DOMAIN-SUFFIX,store.cdn.queniuqe.com,DIRECT",
  "DOMAIN-SUFFIX,steamserver.net,DIRECT",
];

// ======= 核心逻辑 =======
const main = (config) => {
  console.log("🚀 FIClash 脚本开始执行");

  // 确保关键字段存在
  config.proxies ??= [];
  config["proxy-groups"] ??= [];
  config.rules ??= [];

  const allProxyNames = config.proxies.map(p => p.name);
  const groups = config["proxy-groups"];
  // === 处理规则 ===
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

  console.log("🎉 FIClash 配置更新完成");
  return config;
};
