/**
 * Copyright (c) 2026 piiguardrails.com
 *
 * Licensed under the MIT License.
 * See LICENSE.md in the project root for license information.
 */

import type {
	IAuthenticateGeneric,
	ICredentialTestRequest,
	ICredentialType,
	INodeProperties,
	Icon,
} from 'n8n-workflow';

export class PiiGuardrailsApi implements ICredentialType {
	name = 'piiGuardrailsApi';
	displayName = 'Enterprise PII Guardrails API';
	icon: Icon = 'file:piiGuardrails.svg';
	documentationUrl = 'https://www.npmjs.com/package/n8n-nodes-piiguardrails#readme';
	properties: INodeProperties[] = [
		{
			displayName: 'Base URL',
			name: 'baseUrl',
			type: 'string',
			default: 'http://localhost:8000',
			placeholder: 'http://localhost:8000 or https://demo.piiguardrails.com',
			description: 'Base URL of your Enterprise PII Guardrails server instance. For local Docker use http://localhost:8000 (or http://host.containers.internal:8000 in bridge mode). For instant sandbox testing without local setup, use https://demo.piiguardrails.com.',
			required: true,
		},
		{
			displayName: 'API Key',
			name: 'apiKey',
			type: 'string',
			default: '',
			typeOptions: {
				password: true,
			},
			description: 'API key from your Enterprise PII Guardrails Studio dashboard, or copy an instant sandbox key from https://demo.piiguardrails.com',
			required: true,
		},
	];

	authenticate: IAuthenticateGeneric = {
		type: 'generic',
		properties: {
			headers: {
				'x-api-key': '={{$credentials.apiKey}}',
			},
		},
	};

	test: ICredentialTestRequest = {
		request: {
			baseURL: '={{$credentials?.baseUrl}}',
			url: '/health',
			method: 'GET',
		},
	};
}
