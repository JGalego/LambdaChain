import util from 'util';
import stream from 'stream';

import { BedrockChat } from "@langchain/community/chat_models/bedrock";
import { HumanMessage } from "@langchain/core/messages";

const pipeline = util.promisify(stream.pipeline);

const model = new BedrockChat({
  model: process.env.MODEL_ID || "anthropic.claude-3-sonnet-20240229-v1:0",
  region: process.env.AWS_REGION || process.env.AWS_DEFAULT_REGION,
  modelKwargs: {
	anthropic_version: process.env.ANTHROPIC_VERSION || "bedrock-2023-05-31",
	temperature: parseFloat(process.env.TEMPERATURE) || 0.0
  }
});

export const handler = awslambda.streamifyResponse(async (event, responseStream, _context) => {
  const completionStream = await model.stream([
    new HumanMessage({ content: JSON.parse(event.body).message })
  ]);
  await pipeline(completionStream, responseStream);
});