const providerNameMap = {
  // LLM & Intent
  '智谱AI': 'Zhipu AI',
  'Ollama本地模型': 'Ollama Local Model',
  '通义千问': 'Tongyi Qianwen (Qwen)',
  '百炼智能体应用': 'Bailian Agent Application',
  '豆包大模型': 'Doubao LLM',
  '谷歌Gemini': 'Google Gemini',
  '无意图识别': 'No Intent Recognition',
  '外挂的大模型意图识别': 'External LLM Intent Recognition',
  '大模型自主函数调用': 'LLM Autonomous Function Call',
  
  // Memory & Plugins
  '本地短期记忆（总结记忆）': 'Local Short-term Memory (Summarized)',
  '仅上报聊天记录（不总结记忆）': 'Report Chat Logs Only (No Summary)',
  '仅上报聊天记录': 'Report Chat Logs Only',
  '无记忆': 'No Memory',
  '联网搜索': 'Web Search',
  '设备动作调用': 'Call Device Action',
  '火山引擎': 'Volcano Engine',
  '百度文心一言': 'Baidu ERNIE Bot',
  '腾讯混元': 'Tencent Hunyuan',
  '字节豆包': 'ByteDance Doubao',
  '阿里通义千问': 'Aliyun Qwen',
  '讯飞星火': 'iFlytek Spark',

  // TTS (Text to Speech)
  '阿里云(流式)': 'Aliyun TTS (Streaming)',
  'IndexTTS(流式)': 'IndexTTS (Streaming)',
  'PaddleSpeech(流式)': 'PaddleSpeech (Streaming)',
  'PaddleSpeech': 'PaddleSpeech TTS',
  '豆包语音合成': 'Doubao Voice Synthesis',
  '腾讯语音合成': 'Tencent Voice Synthesis',
  '火山双工TTS': 'Volcano Duplex TTS',
  '讯飞语音合成': 'iFlytek Voice Synthesis',
  'MiniMax语音合成': 'MiniMax Voice Synthesis',
  '百度语音合成': 'Baidu Voice Synthesis',
  'Edge语音合成': 'Edge Voice Synthesis',

  // VLLM (Vision LLM)
  '智谱视觉AI': 'Zhipu Vision AI',
  '千问视觉模型': 'Qwen Vision Model',

  // ASR (Speech Recognition)
  '豆包语音识别(流式)': 'Doubao Speech Recognition (Streaming)',
  '豆包语音识别2.0(流式)': 'Doubao Speech Recognition 2.0 (Streaming)',
  '腾讯语音识别': 'Tencent Speech Recognition',
  '百度语音识别': 'Baidu Speech Recognition',
  '豆包语音识别': 'Doubao Speech Recognition',
  '阿里云语音识别': 'Aliyun Speech Recognition',
  '阿里云语音识别(流式)': 'Aliyun Speech Recognition (Streaming)',
  '讯飞语音识别': 'iFlytek Speech Recognition',
  'FunASR语音识别': 'FunASR Speech Recognition',
  'Vosk本地语音识别': 'Vosk Local Speech Recognition',
  'OpenAI语音识别': 'OpenAI Speech Recognition (Whisper)',

  // VAD (Voice Activity Detection)
  '语音活动检测': 'Voice Activity Detection',

  // Agent Template Pills
  '湾湾小何': 'Taiwanese Girl (Xiao He)',
  '星际游子': 'Interstellar Traveler',
  '英语老师': 'English Teacher',
  '好奇男孩': 'Curious Boy',
  '汪汪队长': 'Captain Pup',
  '默认': 'Default',
  '默认模板': 'Default Template'
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

const remarkMap = {
  '无意图识别配置说明：\n1. 不进行意图识别\n2. 所有对话直接传递给LLM处理\n3. 无需额外配置\n4. 适合简单对话场景': 'No Intent Recognition Configuration:\n1. No intent recognition performed\n2. All dialogues passed directly to LLM\n3. No extra configuration required\n4. Suitable for simple dialogue scenarios',
  'LLM意图识别配置说明：\n1. 使用独立的LLM进行意图识别\n2. 默认使用selected_module.LLM的模型\n3. 可以配置使用独立的LLM（如免费的ChatGLMLLM）\n4. 通用性强，但会增加处理时间': 'LLM Intent Recognition Configuration:\n1. Uses an independent LLM for intent recognition\n2. Defaults to selected_module.LLM model\n3. Can be configured to use independent LLMs (e.g. ChatGLMLLM)\n4. Highly versatile, but increases processing latency'
};

export function translateProviderName(name) {
  if (!name) return name;
  return providerNameMap[name] || name;
}

export function translateFieldLabel(label) {
  if (!label) return label;
  return labelNameMap[label] || label;
}

export function translateRemark(remark) {
  if (!remark) return remark;
  return remarkMap[remark] || remark;
}
