const jwt = require('jsonwebtoken');

const authMiddleware = (gruposPermitidos = []) => {
    return (req, res, next) => {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) {
            return res.status(401).json({ error: 'Acesso negado. Token não fornecido.' });
        }

        try {
            const secret = process.env.JWT_SECRET || 'chave_secreta_padrao_academia_plus_2026';
            const decoded = jwt.verify(token, secret);
            req.user = decoded;

            // Se gruposPermitidos foi especificado e não está vazio, valida o perfil
            if (gruposPermitidos.length > 0) {
                const grupoUsuario = (req.user.grupo || '').toUpperCase();
                const permitidosUpper = gruposPermitidos.map(g => g.toUpperCase());

                if (!permitidosUpper.includes(grupoUsuario)) {
                    return res.status(403).json({ 
                        error: 'Acesso restrito. Perfil não autorizado para esta funcionalidade.' 
                    });
                }
            }

            next();
        } catch (error) {
            return res.status(401).json({ error: 'Token inválido ou expirado. Faça login novamente.' });
        }
    };
};

module.exports = authMiddleware;
