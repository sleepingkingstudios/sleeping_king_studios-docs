---
breadcrumbs:
  - name: Documentation
    path: '../../../'
  - name: Versions
    path: '../../'
  - name: '0.1'
    path: '../'
version: '0.1'
---

{% assign root_namespace = site.namespaces | where: "version", page.version | first %}

# SleepingKingStudios::Docs Reference

{% include reference/namespace.md label=false namespace=root_namespace %}

{% include breadcrumbs.md %}
