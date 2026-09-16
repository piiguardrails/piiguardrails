/**
 * Copyright (c) 2026 piiguardrails.com. All Rights Reserved.
 *
 * PROPRIETARY & CONFIDENTIAL.
 * This software and its underlying architecture, protocols, and schemas are protected by
 * intellectual property laws and the Enterprise Software Connector License Agreement.
 * Unauthorized copying, cloning, or distribution is strictly prohibited.
 */
import type { IExecuteFunctions, INodeExecutionData, INodeType, INodeTypeDescription } from 'n8n-workflow';
export declare class PiiGuardrails implements INodeType {
    description: INodeTypeDescription;
    execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]>;
}
