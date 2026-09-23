/**
 * Copyright (c) 2026 piiguardrails.com
 *
 * Licensed under the MIT License.
 * See LICENSE.md in the project root for license information.
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
