# Contributing to Minimal Docker Stacks

Thank you for your interest in contributing to Minimal Docker Stacks! This project aims to provide production-ready, minimal Docker configurations for various web technologies.

## 🎯 Project Goals

- **Minimal Resource Usage** - Optimized for small to medium projects
- **Production Ready** - Secure, performant, and reliable configurations
- **Easy Deployment** - Simple setup with global nginx proxy support
- **Multi-Project Friendly** - No conflicts when running multiple stacks
- **Well Documented** - Clear setup and usage instructions

## 🚀 Ways to Contribute

### 1. **New Technology Stacks**
Add minimal Docker configurations for:
- Laravel (PHP framework)
- Next.js/React (JavaScript framework)
- Django (Python framework)
- Express.js (Node.js framework)
- FastAPI (Python API framework)
- Ruby on Rails
- Go applications
- Any other popular web technology

### 2. **Improvements to Existing Stacks**
- Performance optimizations
- Security enhancements
- Resource usage reductions
- Configuration improvements
- Bug fixes

### 3. **Documentation**
- Setup guides
- Troubleshooting sections
- Resource analysis
- Best practices
- Video tutorials or guides

### 4. **Testing & Validation**
- Test configurations on different environments
- Performance benchmarking
- Security audits
- Resource usage validation

## 📋 Contribution Guidelines

### **Stack Requirements**
Any new technology stack must meet these criteria:

#### **✅ Resource Efficiency**
- **RAM Usage**: <500MB for basic setup
- **Disk Space**: <1GB initial footprint
- **CPU Usage**: <10% average on 1 CPU core
- **Startup Time**: <60 seconds for all services

#### **✅ Production Ready**
- Non-root container execution
- Security hardening implemented
- Health checks configured
- Proper error handling
- Log management setup

#### **✅ Global Nginx Compatible**
- Internal port exposure only (`expose` not `ports`)
- Proxy-ready configuration
- No fixed IP addresses
- Container name based networking

#### **✅ Multi-Project Support**
- Configurable container names via `.env`
- Dynamic network configuration
- No hardcoded values
- Isolated data volumes

## 🛠️ Technical Standards

### **Required Files for New Stack**
```
technology-name/
├── README.md              # Setup and usage guide
├── RESOURCES.md           # Resource analysis
├── docker-compose.yml     # Main orchestration
├── Dockerfile             # Custom container (if needed)
├── env.example           # Environment template
├── .dockerignore         # Build exclusions
└── docker/               # Configuration files
    ├── app/              # Application configs
    ├── nginx/            # Nginx configuration
    ├── database/         # Database configs (if any)
    └── cache/            # Cache configs (if any)
```

### **Configuration Standards**

#### **Environment Variables**
```bash
# Container naming (must be configurable)
APP_CONTAINER_NAME=tech_app
DATABASE_CONTAINER_NAME=tech_db
NGINX_CONTAINER_NAME=tech_nginx

# Application settings
APP_ENV=production
APP_DEBUG=false

# Database configuration
DB_CONNECTION=mysql  # or appropriate
DB_DATABASE=app_db
DB_USERNAME=app_user
DB_PASSWORD=secure_password_here

# Security keys/secrets
# (framework specific)
```

#### **Docker Compose Structure**
```yaml
# Technology Stack Docker Configuration
# Author: Your Name (your@email.com)
# Optimized for: [describe optimization focus]

services:
  app:
    build: .
    container_name: ${APP_CONTAINER_NAME:-tech_app}
    restart: unless-stopped
    environment:
      # Environment specific variables
    volumes:
      # Minimal required volumes
    networks:
      - backend
      - frontend
    security_opt:
      - no-new-privileges:true
    healthcheck:
      # Health check command

  nginx:
    image: nginx:alpine
    container_name: ${NGINX_CONTAINER_NAME:-tech_nginx}
    restart: unless-stopped
    expose:
      - "80"  # Internal only
    # ... rest of config

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

### **Security Requirements**
- All containers run as non-root users
- Security headers configured in nginx
- Sensitive files properly protected
- Rate limiting implemented where applicable
- Input validation and sanitization
- Proper secret management

### **Performance Requirements**
- OPcache or equivalent caching enabled
- Static file caching configured
- Database query optimization
- Minimal dependency installation
- Resource limits properly set

## 📝 Submission Process

### **Step 1: Setup Development Environment**
```bash
# Fork the repository
git clone https://github.com/yourusername/minimal-docker-stacks.git
cd minimal-docker-stacks

# Create your technology branch
git checkout -b add-laravel-stack
# or
git checkout -b improve-wordpress-performance
```

### **Step 2: Create Your Stack**
```bash
# Create new directory for your stack
mkdir laravel
cd laravel

# Create required files
touch README.md RESOURCES.md docker-compose.yml env.example
mkdir -p docker/{app,nginx,database}

# Follow the directory structure and standards
```

### **Step 3: Test Your Configuration**
```bash
# Test basic functionality
docker-compose up -d
docker-compose ps
docker-compose logs

# Test resource usage
docker stats

# Test multi-project compatibility
# (ensure no conflicts with existing stacks)

# Test with global nginx proxy
# (verify internal networking works)
```

### **Step 4: Document Everything**
- **README.md**: Complete setup guide
- **RESOURCES.md**: Resource analysis with actual measurements
- **Code comments**: Explain configuration choices
- **env.example**: All required variables with examples

### **Step 5: Submit Pull Request**
```bash
# Commit your changes
git add .
git commit -m "Add minimal Laravel Docker stack

- Production-ready PHP 8.2 + Laravel setup
- MySQL 8.0 with optimized configuration  
- Nginx reverse proxy ready
- Resource usage: ~280MB RAM, 650MB disk
- Supports 1000+ visitors/day"

# Push to your fork
git push origin add-laravel-stack

# Create pull request with detailed description
```

## 🧪 Testing Checklist

Before submitting, ensure your contribution passes all tests:

### **Functionality Tests**
- [ ] Stack starts without errors
- [ ] All services pass health checks
- [ ] Application is accessible via nginx
- [ ] Database connections work properly
- [ ] File uploads/permissions work
- [ ] Environment variables are properly used

### **Resource Tests**
- [ ] RAM usage documented and verified
- [ ] Disk space usage measured
- [ ] CPU usage under load tested
- [ ] Startup time measured
- [ ] Resource limits respected

### **Multi-Project Tests**
- [ ] Can run alongside WordPress stack
- [ ] No port conflicts
- [ ] No network conflicts
- [ ] Container names are configurable
- [ ] Volumes don't conflict

### **Security Tests**
- [ ] Containers run as non-root
- [ ] No unnecessary ports exposed
- [ ] Security headers present
- [ ] Sensitive files protected
- [ ] Input validation works

### **Documentation Tests**
- [ ] README has complete setup guide
- [ ] RESOURCES.md has actual measurements
- [ ] All configuration options documented
- [ ] Troubleshooting section included
- [ ] Global nginx integration explained

## 🎨 Code Style Guidelines

### **YAML Files**
- Use 2 spaces for indentation
- Quote string values when necessary
- Use descriptive comments
- Group related configurations

### **Shell Scripts**
- Use `#!/bin/bash` shebang
- Include error handling (`set -e`)
- Add descriptive comments
- Use descriptive variable names

### **Documentation**
- Use clear, concise language
- Include code examples
- Add emojis for visual appeal
- Provide troubleshooting steps

## 🏷️ Pull Request Template

When submitting a pull request, please include:

```markdown
## Type of Change
- [ ] New technology stack
- [ ] Bug fix
- [ ] Performance improvement
- [ ] Documentation update
- [ ] Security enhancement

## Description
Brief description of changes and motivation.

## Technology Stack Details
- **Technology**: Laravel 10.x
- **Language**: PHP 8.2
- **Database**: MySQL 8.0
- **Web Server**: Nginx
- **Estimated RAM**: 280MB
- **Estimated Disk**: 650MB

## Testing
- [ ] Tested on development environment
- [ ] Verified resource usage
- [ ] Tested with global nginx proxy
- [ ] Confirmed multi-project compatibility
- [ ] All health checks pass

## Documentation
- [ ] README.md updated
- [ ] RESOURCES.md included
- [ ] Code comments added
- [ ] env.example provided

## Checklist
- [ ] Code follows project guidelines
- [ ] Self-review completed
- [ ] Documentation is clear and complete
- [ ] No conflicts with existing stacks
```

## 🌟 Recognition

Contributors will be:
- Added to the contributors list in README.md
- Credited in the specific stack documentation
- Mentioned in release notes
- Given appropriate GitHub badges and recognition

## 📞 Getting Help

- **Questions**: Open an issue with the `question` label
- **Discussions**: Use GitHub Discussions for general topics
- **Security Issues**: Email soman@devkraken.com directly
- **Feature Requests**: Open an issue with the `enhancement` label

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

## 👨‍💻 Maintainer

**DevKraken**  
Email: soman@devkraken.com  

Thank you for helping make web development more efficient! 🚀 