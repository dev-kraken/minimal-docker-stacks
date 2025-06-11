## 🎯 Type of Change

- [ ] 🚀 New technology stack
- [ ] 🐛 Bug fix
- [ ] ⚡ Performance improvement
- [ ] 📚 Documentation update
- [ ] 🔒 Security enhancement
- [ ] 🧹 Code cleanup/refactoring

## 📋 Description

**What does this PR do?**
A clear and concise description of the changes and motivation.

**Related Issue**: #(issue number)

## 🛠️ Technology Stack Details

*(Fill this section only for new stacks)*

- **Technology**: 
- **Language/Runtime**: 
- **Database**: 
- **Web Server**: 
- **Estimated RAM**: MB
- **Estimated Disk**: MB
- **Target Use Case**: 

## ✅ Testing Checklist

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
- [ ] Startup time measured (<60 seconds)
- [ ] Resource limits respected

### **Multi-Project Tests**
- [ ] Can run alongside other stacks
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
- [ ] RESOURCES.md included (for new stacks)
- [ ] All configuration options documented
- [ ] Troubleshooting section included
- [ ] Global nginx integration explained

## 📊 Resource Measurements

**Actual measurements from testing**:

```bash
# Docker stats output
CONTAINER ID   NAME       CPU %   MEM USAGE / LIMIT   MEM %   NET I/O     BLOCK I/O   PIDS
abcd1234       tech_app   2.5%    180MB / 512MB      35%     1kB / 2kB   0B / 0B     15
```

**Disk usage**:
```bash
# du -sh output
350MB   ./technology-stack/
```

## 🔧 Configuration Changes

**Files modified/added**:
- [ ] docker-compose.yml
- [ ] Dockerfile
- [ ] README.md
- [ ] RESOURCES.md
- [ ] env.example
- [ ] .dockerignore
- [ ] Configuration files in docker/

**Breaking changes**: [ ] Yes [ ] No
**If yes, describe**: 

## 🌐 Global Nginx Integration

**Tested with global nginx proxy**: [ ] Yes [ ] No

**Example nginx configuration**:
```nginx
server {
    server_name example.com;
    location / {
        proxy_pass http://your_container_name:80;
        # ... proxy headers
    }
}
```

## 📚 Documentation

- [ ] Code comments added/updated
- [ ] README.md updated
- [ ] RESOURCES.md included
- [ ] env.example provided
- [ ] Inline documentation clear

## 🔍 Code Quality

- [ ] Code follows project guidelines
- [ ] Self-review completed
- [ ] No hardcoded values
- [ ] Error handling implemented
- [ ] Resource limits properly set

## 🚀 Deployment

**Tested on**:
- [ ] Local development
- [ ] VPS/Cloud server
- [ ] Different OS (specify): 

**Minimum requirements verified**:
- [ ] 1GB RAM
- [ ] 20GB disk space
- [ ] 1 CPU core

## 📸 Screenshots

*(Optional) Add screenshots showing the working application*

## 💭 Additional Notes

Any additional information, concerns, or considerations for reviewers.

---

## 📋 Reviewer Checklist

*(For maintainers)*

- [ ] Code quality review completed
- [ ] Resource efficiency verified
- [ ] Security review passed
- [ ] Documentation review completed
- [ ] Testing instructions followed
- [ ] Multi-project compatibility confirmed

---

**By submitting this PR, I confirm that**:
- [ ] I have read the [Contributing Guidelines](CONTRIBUTING.md)
- [ ] My code follows the project standards
- [ ] I have tested my changes thoroughly
- [ ] I have provided appropriate documentation
- [ ] I agree to the project license terms 