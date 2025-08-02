# Railway Deployment Guide for Traccar GPS Tracking Application

This guide will help you deploy your Traccar GPS tracking application to Railway.

## Prerequisites

1. Railway account (sign up at [railway.app](https://railway.app))
2. Git repository with your code
3. Railway CLI (optional but recommended)

## Quick Deployment Steps

### 1. Create a New Railway Project

```bash
# Install Railway CLI (optional)
npm install -g @railway/cli

# Login to Railway
railway login

# Create new project
railway new
```

Or use the Railway dashboard to create a new project.

### 2. Connect Your Repository

- Go to your Railway dashboard
- Click "New Project"
- Select "Deploy from GitHub repo"
- Choose your repository

### 3. Add PostgreSQL Database

Railway will automatically detect that you need a database. Add PostgreSQL:

- In your Railway project dashboard
- Click "New" → "Database" → "Add PostgreSQL"
- Railway will automatically create connection environment variables

### 4. Configure Environment Variables

Set the following environment variables in your Railway project:

#### Required Variables (Auto-configured by Railway)

- `DATABASE_URL` - Auto-configured by Railway PostgreSQL
- `PGUSER` - Auto-configured by Railway PostgreSQL
- `PGPASSWORD` - Auto-configured by Railway PostgreSQL
- `PORT` - Auto-configured by Railway

#### Optional Email Configuration

```
MAIL_SMTP_HOST=smtp.your-provider.com
MAIL_SMTP_PORT=587
MAIL_SMTP_SSL=true
MAIL_SMTP_USERNAME=your-email@domain.com
MAIL_SMTP_PASSWORD=your-email-password
MAIL_FROM=noreply@yourdomain.com
```

#### Optional Application Settings

```
JAVA_OPTS=-Xms512m -Xmx1024m
NODE_ENV=production
```

### 5. Deploy

Railway will automatically deploy when you push to your main branch. The deployment process:

1. **Frontend Build**: Builds the React application using Vite
2. **Backend Build**: Compiles Java application using Gradle
3. **Database Setup**: Runs Liquibase migrations automatically
4. **Service Start**: Starts the Traccar server

## Application Architecture

### Frontend (React + Vite)

- Built into `./web` directory
- Served by Jetty server
- Material-UI components
- Real-time updates via WebSocket

### Backend (Java + Jetty)

- Main class: `org.traccar.Main`
- Default port: 8082 (overridden by Railway's PORT)
- RESTful API at `/api/*`
- WebSocket endpoint at `/api/socket`

### Database

- PostgreSQL (recommended for production)
- Automatic migrations via Liquibase
- Schema files in `./schema/` directory

## File Structure

```
├── Dockerfile              # Multi-stage build configuration
├── railway.toml            # Railway deployment configuration
├── production.xml          # Production configuration file
├── build.gradle           # Java build configuration
├── enroute-app/           # React frontend
│   ├── package.json
│   ├── vite.config.ts
│   └── src/
└── src/main/java/         # Java backend
    └── org/traccar/
```

## Access Your Application

After successful deployment:

1. **Web Interface**: `https://your-app-name.up.railway.app`
2. **API**: `https://your-app-name.up.railway.app/api`
3. **WebSocket**: `wss://your-app-name.up.railway.app/api/socket`

## Default Login

- **Username**: `admin`
- **Password**: `admin`

⚠️ **Important**: Change the default credentials immediately after first login!

## GPS Device Configuration

Configure your GPS devices to send data to:

- **Host**: `your-app-name.up.railway.app`
- **Port**: `443` (HTTPS)
- **Protocol**: Depends on your device (check Traccar documentation)

## Troubleshooting

### Build Failures

1. **Java Build Issues**:

   ```bash
   # Check Gradle build locally
   ./gradlew build
   ```

2. **Frontend Build Issues**:
   ```bash
   # Check Vite build locally
   cd enroute-app
   npm run build
   ```

### Runtime Issues

1. **Database Connection**:

   - Verify PostgreSQL addon is attached
   - Check `DATABASE_URL` environment variable

2. **Port Issues**:

   - Railway automatically sets PORT variable
   - Application binds to `0.0.0.0:$PORT`

3. **Memory Issues**:
   - Adjust `JAVA_OPTS` environment variable
   - Example: `JAVA_OPTS=-Xms256m -Xmx512m`

### Logs

View logs in Railway dashboard or via CLI:

```bash
railway logs
```

## Custom Domain (Optional)

1. Go to your Railway project settings
2. Add custom domain
3. Configure DNS records as instructed
4. SSL certificate is automatically provided

## Scaling

Railway automatically handles:

- Load balancing
- SSL termination
- Health checks
- Auto-restarts on failure

## Security Considerations

1. **Change Default Credentials**: Update admin password immediately
2. **Environment Variables**: Never commit sensitive data to git
3. **HTTPS**: Always use HTTPS in production (automatic on Railway)
4. **Database**: Use strong PostgreSQL credentials
5. **Firewall**: Configure device protocols securely

## Support

- **Railway Documentation**: [docs.railway.app](https://docs.railway.app)
- **Traccar Documentation**: [traccar.org](https://www.traccar.org)
- **Issues**: Create GitHub issues for application-specific problems

## Cost Optimization

- Railway offers free tier with limitations
- Monitor usage in Railway dashboard
- Optimize Java memory settings with `JAVA_OPTS`
- Consider upgrading for production use

---

**Note**: This deployment configuration is optimized for Railway's environment with PostgreSQL database and automatic SSL. The application will be accessible via HTTPS and will automatically handle database migrations on first startup.
