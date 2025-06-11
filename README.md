# Minimal Docker Stacks

Production-ready, minimal Docker configurations for various web technologies. Optimized for small to medium projects with focus on resource efficiency and performance.

## 🚀 Available Stacks

- **[WordPress](./minimal-wordpress/)** - Minimal WordPress with PHP-FPM, MySQL, Nginx (~300MB RAM)
  - Perfect for landing pages, business sites, portfolios
  - Resource usage: 240-340MB RAM, 600-900MB disk
  - Supports 1000+ visitors/day on $5/month VPS

*More stacks coming soon...*

## 🎯 Project Goals

- **⚡ Minimal Resource Usage** - Optimized for cost-effective hosting
- **🛡️ Production Ready** - Secure, performant, and reliable
- **🌐 Global Nginx Ready** - Works seamlessly with reverse proxies
- **🔄 Multi-Project Friendly** - Run multiple stacks without conflicts
- **📚 Well Documented** - Clear setup and usage instructions

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/dev-kraken/minimal-docker-stacks.git
   cd minimal-docker-stacks
   ```

2. **Choose your stack**
   ```bash
   cd minimal-wordpress  # or any other stack
   ```

3. **Follow the stack-specific README**
   - Configure environment variables
   - Create required directories
   - Start with `docker-compose up -d`

## 📊 Resource Comparison

| Stack | RAM Usage | Disk Space | VPS Cost | Capacity |
|-------|-----------|------------|----------|----------|
| WordPress | 240-340MB | 600-900MB | $5-10/month | 1000+ visitors/day |
| Laravel | Coming Soon | Coming Soon | Coming Soon | Coming Soon |
| Next.js | Coming Soon | Coming Soon | Coming Soon | Coming Soon |

## 🤝 Contributing

We welcome contributions! Help us add more minimal Docker configurations for popular web technologies.

### **Ways to Contribute**
- 🚀 **New Technology Stacks** - Laravel, Next.js, Django, Express.js, etc.
- 🐛 **Bug Fixes** - Improvements to existing configurations
- 📚 **Documentation** - Better guides and troubleshooting
- ⚡ **Performance** - Resource optimizations and benchmarks

### **Contribution Requirements**
- **Resource Efficient**: <500MB RAM, <1GB disk
- **Production Ready**: Security hardened, health checks
- **Global Nginx Compatible**: Internal networking only
- **Multi-Project Support**: Configurable container names
- **Well Documented**: Complete setup guide + resource analysis

### **Get Started**
1. Read our [Contributing Guidelines](CONTRIBUTING.md)
2. Check [open issues](https://github.com/dev-kraken/minimal-docker-stacks/issues) for ideas
3. Use our [issue templates](.github/ISSUE_TEMPLATE/) to propose new stacks
4. Follow our [pull request template](.github/PULL_REQUEST_TEMPLATE.md) for submissions

## 🌟 Why These Configurations?

### **vs Standard Docker Setups**
- **60-70% less RAM usage** - More cost-effective hosting
- **70-80% less disk space** - Faster deployments
- **40-60% less CPU usage** - Better performance
- **2-3x faster response times** - Optimized configurations

### **vs Shared Hosting**
- **Full control** - No restrictions or limitations
- **Guaranteed resources** - No "unlimited" overselling
- **Better performance** - Dedicated resources
- **Easy scaling** - Horizontal and vertical scaling

### **Perfect For**
- Small business websites
- Landing pages and portfolios
- API services
- Development environments
- Cost-conscious hosting
- Multiple client projects

## 📞 Support

- **🐛 Bug Reports**: Use our [bug report template](.github/ISSUE_TEMPLATE/bug-report.md)
- **💡 Feature Requests**: Use our [new stack template](.github/ISSUE_TEMPLATE/new-stack.md)
- **💬 Discussions**: GitHub Discussions for general questions
- **🔒 Security Issues**: Email soman@devkraken.com directly

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👨‍💻 Author

**DevKraken**  
Email: soman@devkraken.com

*Building efficient Docker solutions for modern web development*

---

⭐ **Star this repo** if you find it useful and help others discover efficient Docker configurations!