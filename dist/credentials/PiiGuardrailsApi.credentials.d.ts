/**
 * Copyright (c) 2026 piiguardrails.com. All Rights Reserved.
 *
 * PROPRIETARY & CONFIDENTIAL.
 * This software and its underlying architecture and schemas are protected by intellectual
 * property laws and the Enterprise Software Connector License Agreement.
 * Unauthorized copying, cloning, or distribution is strictly prohibited.
 */
import type { IAuthenticateGeneric, ICredentialTestRequest, ICredentialType, INodeProperties, Icon } from 'n8n-workflow';
export declare class PiiGuardrailsApi implements ICredentialType {
    name: string;
    displayName: string;
    icon: Icon;
    documentationUrl: string;
    properties: INodeProperties[];
    authenticate: IAuthenticateGeneric;
    test: ICredentialTestRequest;
}
