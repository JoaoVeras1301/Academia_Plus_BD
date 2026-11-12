/**
 * ACADEMIA+ | PAINEL DE DEMONSTRAÇÃO TÉCNICA MYSQL
 * Controla os testes acadêmicos interativos solicitados pelo professor
 */

document.addEventListener('DOMContentLoaded', () => {
    checkAuth(['ADMINISTRADOR']);

    // 1. DEMONSTRAÇÃO DE COMMIT
    document.getElementById('btn-demo-commit')?.addEventListener('click', async () => {
        const terminal = document.getElementById('terminal-tcl');
        terminal.innerHTML = '<span class="log-step">Iniciando transação com sucesso no MySQL...</span>\n';

        try {
            const data = await apiFetch('/demonstracao/tcl/sucesso', { method: 'POST' });
            if (!data) return;

            let output = data.logs.map(log => {
                if (log.includes('COMMIT finalizado') || log.includes('sucesso')) {
                    return `<span class="log-success">${log}</span>`;
                }
                return `<span class="log-step">${log}</span>`;
            }).join('\n');

            output += `\n\n<span class="log-success">=== COMPROVAÇÃO DE PERSISTÊNCIA (COMMIT) ===</span>\n`;
            output += `Matrícula ID: ${data.matricula.id_matricula} | Código: ${data.matricula.codigo_matricula}\n`;
            output += `Aluno: ${data.matricula.aluno} | Plano: ${data.matricula.plano}\n`;
            output += `Total de mensalidades geradas e commitadas: ${data.total_mensalidades_geradas}\n`;

            terminal.innerHTML = output;
        } catch (err) {
            terminal.innerHTML += `\n<span class="log-error">FALHA: ${err.message}</span>`;
        }
    });

    // 2. DEMONSTRAÇÃO DE ROLLBACK
    document.getElementById('btn-demo-rollback')?.addEventListener('click', async () => {
        const terminal = document.getElementById('terminal-tcl');
        terminal.innerHTML = '<span class="log-step">Iniciando teste de falha proposital para acionamento de ROLLBACK...</span>\n';

        try {
            const data = await apiFetch('/demonstracao/tcl/falha', { method: 'POST' });
            if (!data) return;

            let output = data.logs.map(log => {
                if (log.includes('ERRO CAPTURADO') || log.includes('FALHA')) {
                    return `<span class="log-error">${log}</span>`;
                }
                if (log.includes('ROLLBACK concluído') || log.includes('garantidas')) {
                    return `<span class="log-warning">${log}</span>`;
                }
                return `<span class="log-step">${log}</span>`;
            }).join('\n');

            output += `\n\n<span class="log-warning">=== RESULTADO DO ROLLBACK ===</span>\n`;
            output += `Código Temporário Testado: ${data.comprovacao.codigo_testado}\n`;
            output += `Registros restantes no banco: ${data.comprovacao.registros_encontrados_apos_rollback} (Zero)\n`;
            output += `Conclusão: ${data.comprovacao.resultado}\n`;

            terminal.innerHTML = output;
        } catch (err) {
            terminal.innerHTML += `\n<span class="log-error">FALHA: ${err.message}</span>`;
        }
    });

    // 3. CONSULTA DE VIEWS
    document.getElementById('btn-view-alunos')?.addEventListener('click', async () => {
        const container = document.getElementById('container-view');
        container.innerHTML = '<div style="text-align: center; color: var(--text-muted);"><i class="fa-solid fa-spinner fa-spin"></i> Consultando View vw_alunos_ativos...</div>';

        try {
            const res = await apiFetch('/demonstracao/views/alunos-ativos');
            if (!res || !res.dados) return;

            container.innerHTML = `
                <div style="margin-bottom: 12px; font-weight: 600; color: var(--accent-green);">
                    <i class="fa-solid fa-check"></i> VIEW: vw_alunos_ativos (${res.total_retornado} registros retornados)
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Código Aluno</th>
                                <th>Nome</th>
                                <th>Telefone</th>
                                <th>Plano Atual</th>
                                <th>Início</th>
                                <th>Término</th>
                                <th>Situação</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${res.dados.map(a => `
                                <tr>
                                    <td><strong>${a.codigo_aluno}</strong></td>
                                    <td>${a.nome_aluno}</td>
                                    <td>${a.telefone}</td>
                                    <td><span class="badge badge-info">${a.plano_atual}</span></td>
                                    <td>${formatData(a.data_inicio)}</td>
                                    <td>${formatData(a.data_fim)}</td>
                                    <td><span class="badge badge-success">${a.situacao}</span></td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `;
        } catch (err) {
            container.innerHTML = `<div style="color: var(--accent-red);">Erro ao consultar View: ${err.message}</div>`;
        }
    });

    document.getElementById('btn-view-mensalidades')?.addEventListener('click', async () => {
        const container = document.getElementById('container-view');
        container.innerHTML = '<div style="text-align: center; color: var(--text-muted);"><i class="fa-solid fa-spinner fa-spin"></i> Consultando View vw_mensalidades_pendentes...</div>';

        try {
            const res = await apiFetch('/demonstracao/views/mensalidades-pendentes');
            if (!res || !res.dados) return;

            container.innerHTML = `
                <div style="margin-bottom: 12px; font-weight: 600; color: var(--accent-green);">
                    <i class="fa-solid fa-check"></i> VIEW: vw_mensalidades_pendentes (${res.total_retornado} registros retornados)
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Nome Aluno</th>
                                <th>Plano</th>
                                <th>Parcela</th>
                                <th>Valor</th>
                                <th>Valor Pago</th>
                                <th>Saldo</th>
                                <th>Vencimento</th>
                                <th>Situação Financeira</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${res.dados.map(m => `
                                <tr>
                                    <td><strong>${m.nome_aluno}</strong></td>
                                    <td>${m.nome_plano}</td>
                                    <td>Parcela ${m.numero_parcela}</td>
                                    <td>${formatMoeda(m.valor)}</td>
                                    <td>${formatMoeda(m.valor_pago)}</td>
                                    <td><strong style="color: var(--accent-amber);">${formatMoeda(m.saldo)}</strong></td>
                                    <td>${formatData(m.data_vencimento)}</td>
                                    <td>
                                        <span class="badge ${m.situacao_financeira === 'ATRASADA' ? 'badge-danger' : 'badge-warning'}">
                                            ${m.situacao_financeira}
                                        </span>
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `;
        } catch (err) {
            container.innerHTML = `<div style="color: var(--accent-red);">Erro ao consultar View: ${err.message}</div>`;
        }
    });

    // 4. TESTAR STORED FUNCTIONS
    document.getElementById('btn-testar-functions')?.addEventListener('click', async () => {
        const container = document.getElementById('container-functions');
        container.innerHTML = '<div style="text-align: center; color: var(--text-muted);"><i class="fa-solid fa-spinner fa-spin"></i> Executando Functions no MySQL...</div>';

        try {
            const res = await apiFetch('/demonstracao/functions/teste');
            if (!res) return;

            container.innerHTML = `
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 20px;">
                    <div style="background-color: var(--bg-primary); padding: 16px; border-radius: var(--radius-sm); border: 1px solid var(--border-color);">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); font-weight: 700;">
                            fn_gerar_id_aluno() [NOT DETERMINISTIC]
                        </div>
                        <div style="font-size: 18px; font-weight: 800; color: var(--accent-green); margin-top: 6px;">
                            ${res.funcoes_geracao.codigo_aluno}
                        </div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Código de negócio gerado dinamicamente</div>
                    </div>

                    <div style="background-color: var(--bg-primary); padding: 16px; border-radius: var(--radius-sm); border: 1px solid var(--border-color);">
                        <div style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); font-weight: 700;">
                            fn_gerar_id_matricula() [NOT DETERMINISTIC]
                        </div>
                        <div style="font-size: 18px; font-weight: 800; color: var(--accent-blue); margin-top: 6px;">
                            ${res.funcoes_geracao.codigo_matricula}
                        </div>
                        <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Código de contrato gerado dinamicamente</div>
                    </div>
                </div>

                <div style="font-weight: 600; color: var(--text-primary); margin-bottom: 10px;">
                    Demonstração de Cálculos por Function em Mensalidades Reais:
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>ID Mensalidade</th>
                                <th>Valor Nominal</th>
                                <th>Valor Pago</th>
                                <th>fn_calcular_saldo_mensalidade()</th>
                                <th>fn_verificar_situacao_mensalidade()</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${res.funcoes_calculo.map(c => `
                                <tr>
                                    <td>#${c.id_mensalidade}</td>
                                    <td>${formatMoeda(c.valor)}</td>
                                    <td>${formatMoeda(c.valor_pago)}</td>
                                    <td><strong style="color: var(--accent-green);">${formatMoeda(c.saldo_calculado)}</strong></td>
                                    <td><span class="badge badge-info">${c.situacao_calculada}</span></td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `;
        } catch (err) {
            container.innerHTML = `<div style="color: var(--accent-red);">Erro: ${err.message}</div>`;
        }
    });

    // 5. TRIGGER DE AUDITORIA
    document.getElementById('btn-ver-triggers')?.addEventListener('click', async () => {
        const container = document.getElementById('container-triggers');
        container.innerHTML = '<div style="text-align: center; color: var(--text-muted);"><i class="fa-solid fa-spinner fa-spin"></i> Consultando tabela de auditoria...</div>';

        try {
            const res = await apiFetch('/demonstracao/triggers/auditoria');
            if (!res || !res.registros) return;

            if (res.registros.length === 0) {
                container.innerHTML = '<div style="text-align: center; color: var(--text-muted); padding: 20px;">Nenhum pagamento registrado para auditoria ainda.</div>';
                return;
            }

            container.innerHTML = `
                <div style="margin-bottom: 12px; font-weight: 600; color: var(--accent-green);">
                    <i class="fa-solid fa-bolt"></i> Trigger <code>${res.trigger}</code> executada com sucesso a cada INSERT em pagamentos:
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>ID Auditoria</th>
                                <th>ID Pagamento</th>
                                <th>ID Mensalidade</th>
                                <th>Valor Quitado</th>
                                <th>Forma Pagto</th>
                                <th>Data/Hora Registro</th>
                                <th>Usuário Responsável (SGBD)</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${res.registros.map(r => `
                                <tr>
                                    <td><strong>#${r.id_auditoria}</strong></td>
                                    <td>#${r.id_pagamento}</td>
                                    <td>#${r.id_mensalidade}</td>
                                    <td><strong style="color: var(--accent-green);">${formatMoeda(r.valor_pago)}</strong></td>
                                    <td><span class="badge badge-info">${r.forma_pagamento}</span></td>
                                    <td>${new Date(r.data_registro).toLocaleString('pt-BR')}</td>
                                    <td><span class="badge badge-secondary">${r.usuario_responsavel}</span></td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `;
        } catch (err) {
            container.innerHTML = `<div style="color: var(--accent-red);">Erro: ${err.message}</div>`;
        }
    });

    // 6. ANÁLISE DE ÍNDICES COM EXPLAIN
    document.getElementById('btn-analisar-indices')?.addEventListener('click', async () => {
        const container = document.getElementById('container-indices');
        container.innerHTML = '<div style="text-align: center; color: var(--text-muted);"><i class="fa-solid fa-spinner fa-spin"></i> Executando EXPLAIN no MySQL...</div>';

        try {
            const res = await apiFetch('/demonstracao/indices');
            if (!res) return;

            container.innerHTML = `
                <div style="display: flex; flex-direction: column; gap: 20px;">
                    <div style="background-color: var(--bg-primary); padding: 16px; border-radius: var(--radius-sm); border: 1px solid var(--border-color);">
                        <div style="font-size: 12px; color: var(--text-muted); text-transform: uppercase; font-weight: bold;">
                            Consulta 1 (Mensalidades Vencidas / Pendentes)
                        </div>
                        <div style="font-family: monospace; font-size: 13px; color: #38bdf8; margin: 6px 0;">
                            ${res.consulta_1.sql}
                        </div>
                        <div style="display: flex; gap: 20px; flex-wrap: wrap; margin-top: 10px; font-size: 13px;">
                            <div><strong>Índice Utilizado:</strong> <span class="badge badge-success">${res.consulta_1.indice_utilizado}</span></div>
                            <div><strong>Tipo de Acesso:</strong> ${res.consulta_1.tipo_acesso}</div>
                            <div><strong>Linhas Estimadas:</strong> ${res.consulta_1.linhas_examinadas}</div>
                        </div>
                    </div>

                    <div style="background-color: var(--bg-primary); padding: 16px; border-radius: var(--radius-sm); border: 1px solid var(--border-color);">
                        <div style="font-size: 12px; color: var(--text-muted); text-transform: uppercase; font-weight: bold;">
                            Consulta 2 (Busca de Alunos por Nome)
                        </div>
                        <div style="font-family: monospace; font-size: 13px; color: #38bdf8; margin: 6px 0;">
                            ${res.consulta_2.sql}
                        </div>
                        <div style="display: flex; gap: 20px; flex-wrap: wrap; margin-top: 10px; font-size: 13px;">
                            <div><strong>Índice Utilizado:</strong> <span class="badge badge-success">${res.consulta_2.indice_utilizado}</span></div>
                            <div><strong>Tipo de Acesso:</strong> ${res.consulta_2.tipo_acesso}</div>
                            <div><strong>Linhas Estimadas:</strong> ${res.consulta_2.linhas_examinadas}</div>
                        </div>
                    </div>
                </div>
            `;
        } catch (err) {
            container.innerHTML = `<div style="color: var(--accent-red);">Erro: ${err.message}</div>`;
        }
    });

    // 7. PERMISSÕES E USUÁRIOS
    document.getElementById('btn-ver-permissoes')?.addEventListener('click', async () => {
        const container = document.getElementById('container-permissoes');
        container.innerHTML = '<div style="text-align: center; color: var(--text-muted);"><i class="fa-solid fa-spinner fa-spin"></i> Verificando privilégios...</div>';

        try {
            const res = await apiFetch('/demonstracao/permissoes');
            if (!res) return;

            const grantsHtml = res.privilegios_app.map(g => `<li style="font-family: monospace; font-size: 12px; margin-bottom: 4px; color: #a7f3d0;">${g}</li>`).join('');

            container.innerHTML = `
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 20px;">
                    <div>
                        <div class="form-label">Usuário Conectado no MySQL</div>
                        <div style="font-weight: 800; color: var(--accent-green); font-size: 16px;">${res.usuario_conectado}</div>
                    </div>
                    <div>
                        <div class="form-label">Servidor / Host</div>
                        <div style="font-weight: 600;">${res.servidor}</div>
                    </div>
                    <div>
                        <div class="form-label">Database Ativo</div>
                        <div style="font-weight: 600;">${res.banco}</div>
                    </div>
                    <div>
                        <div class="form-label">Política de Segurança</div>
                        <div style="color: var(--accent-blue); font-size: 13px;">${res.politica_seguranca}</div>
                    </div>
                </div>

                <div style="background-color: var(--bg-primary); padding: 16px; border-radius: var(--radius-sm); border: 1px solid var(--border-color);">
                    <div style="font-size: 13px; font-weight: 700; margin-bottom: 8px; color: var(--text-primary);">
                        <i class="fa-solid fa-list-check"></i> Privilégios Concedidos (SHOW GRANTS):
                    </div>
                    <ul style="padding-left: 20px;">${grantsHtml}</ul>
                </div>
            `;
        } catch (err) {
            container.innerHTML = `<div style="color: var(--accent-red);">Erro: ${err.message}</div>`;
        }
    });
});
