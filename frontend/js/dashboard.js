/**
 * ACADEMIA+ | CONTROLLER DE DASHBOARD
 * Consulta métricas em tempo real vindas da API Node.js/MySQL
 */

document.addEventListener('DOMContentLoaded', async () => {
    // Valida se o usuário está autenticado
    const { token } = getSession();
    if (!token) return;

    try {
        const data = await apiFetch('/dashboard');
        if (!data) return;

        // Atualiza os indicadores do dashboard
        document.getElementById('count-alunos').textContent = data.alunos_ativos;
        document.getElementById('count-funcionarios').textContent = data.funcionarios_ativos;
        document.getElementById('count-matriculas').textContent = data.matriculas_ativas;
        document.getElementById('count-pendentes').textContent = data.mensalidades_pendentes;
        document.getElementById('count-atrasadas').textContent = data.mensalidades_atrasadas;
        document.getElementById('valor-receita').textContent = formatMoeda(data.receita_mes);

        // Preenche tabela de matrículas recentes
        const tbody = document.getElementById('tabela-recentes-matriculas');
        if (tbody) {
            if (!data.ultimas_matriculas || data.ultimas_matriculas.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: var(--text-muted); padding: 24px;">Nenhuma matrícula cadastrada até o momento.</td></tr>';
                return;
            }

            tbody.innerHTML = data.ultimas_matriculas.map(m => `
                <tr>
                    <td><strong>${m.codigo_matricula || 'MAT-' + m.id_matricula}</strong></td>
                    <td>${m.aluno_nome}</td>
                    <td><span class="badge badge-info">${m.plano_nome}</span></td>
                    <td>${formatData(m.data_inicio)}</td>
                    <td><strong>${formatMoeda(m.valor_contratado)}</strong></td>
                    <td><span class="badge badge-${m.status.toLowerCase()}">${m.status}</span></td>
                </tr>
            `).join('');
        }
    } catch (error) {
        console.error('Falha ao obter métricas do dashboard:', error);
        document.querySelectorAll('.metric-value').forEach(el => el.textContent = '-');
        const tbody = document.getElementById('tabela-recentes-matriculas');
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: var(--accent-red); padding: 24px;">Erro ao carregar dados do banco. Verifique a conexão do backend.</td></tr>';
        }
    }
});
