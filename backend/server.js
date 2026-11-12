const app = require('./src/app');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '.env') });
require('dotenv').config();

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log('====================================================');
    console.log(` Academia+ Backend API rodando com sucesso!`);
    console.log(` URL da API:      http://localhost:${PORT}/api/health`);
    console.log(` Interface Web:   http://localhost:${PORT}/index.html`);
    console.log('====================================================');
});
