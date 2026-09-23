/**
 * Copyright (c) 2026 piiguardrails.com
 *
 * Licensed under the MIT License.
 * See LICENSE.md in the project root for license information.
 */
import type { IExecuteFunctions, INodeExecutionData, INodeType, INodeTypeDescription } from 'n8n-workflow';
export declare class PiiGuardrails implements INodeType {
    description: INodeTypeDescription;
    execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]>;
}
