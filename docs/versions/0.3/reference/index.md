---
breadcrumbs:
- name: Documentation
  path: "/"
- name: Versions
  path: "/versions"
- name: Version 0.3
  path: "/versions/0.3"
version: '0.3'
---

{% assign root_namespace = site.namespaces | where: "version", page.version | first %}

# {{ site.project_metadata.name }} Reference

{% include reference/namespace.md label=false namespace=root_namespace %}
