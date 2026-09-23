"use strict";
/**
 * Copyright (c) 2026 piiguardrails.com
 *
 * Licensed under the MIT License.
 * See LICENSE.md in the project root for license information.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.PiiGuardrailsApi = void 0;
class PiiGuardrailsApi {
    constructor() {
        this.name = 'piiGuardrailsApi';
        this.displayName = 'Enterprise PII Guardrails API';
        this.icon = 'file:piiGuardrails.svg';
        this.documentationUrl = 'https://www.npmjs.com/package/n8n-nodes-piiguardrails#readme';
        this.properties = [
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
        this.authenticate = {
            type: 'generic',
            properties: {
                headers: {
                    'x-api-key': '={{$credentials.apiKey}}',
                },
            },
        };
        this.test = {
            request: {
                baseURL: '={{$credentials?.baseUrl}}',
                url: '/health',
                method: 'GET',
            },
        };
    }
}
exports.PiiGuardrailsApi = PiiGuardrailsApi;
