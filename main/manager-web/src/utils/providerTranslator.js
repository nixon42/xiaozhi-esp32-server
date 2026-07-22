const providerNameMap = {
  '外挂的大模型意图识别': 'External LLM Intent Recognition',
  '大模型自主函数调用': 'LLM Autonomous Function Call',
  '本地短期记忆（总结记忆）': 'Local Short-term Memory (Summarized)',
  '仅上报聊天记录（不总结记忆）': 'Report Chat Logs Only (No Summary)',
  '仅上报聊天记录': 'Report Chat Logs Only',
  '联网搜索': 'Web Search',
  '设备动作调用': 'Call Device Action'
};

const labelNameMap = {
  '引用的LLM模型': 'Referenced LLM Model',
  'LLM模型': 'LLM Model',
  '应用ID': 'App ID',
  '访问令牌': 'Access Token',
  '热词文件名称': 'Hot Words File Name',
  '替换词文件名称': 'Replacement Words File Name',
  '输出目录': 'Output Directory',
  '静音判定时长(ms)': 'Silence Window (ms)',
  '是否开启多语种识别模式': 'Enable Multilingual Mode',
  '指定语言编码': 'Language Code',
  '资源ID': 'Resource ID',
  '服务地址': 'Server Host',
  '端口号': 'Port Number',
  'API密钥': 'API Key',
  '工具描述': 'Tool Description',
  '返回数量': 'Return Limit'
};

export function translateProviderName(name) {
  if (!name) return name;
  return providerNameMap[name] || name;
}

export function translateFieldLabel(label) {
  if (!label) return label;
  return labelNameMap[label] || label;
}
