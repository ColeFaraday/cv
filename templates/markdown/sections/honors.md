{% extends "section.md" %}

{% block body %}
<table class="table table-hover">
{% for award in items %}
<tr>
  <td>
  <div style='float: right'>{{ award.year }}</div>
  <div>
    {% if award.url %}
        <a href="{{award.url}}">{{ award.title }}</a>
    {% else %}
        {{ award.title }}
    {% endif %}
    {% if award.descr %}
    <br><p style="color:grey; font-size:0.9rem">{{ award.descr }}</p>
    {% endif %}
  </div>
  </td>
  <!-- <td class='col-md-2' style='text-align:right;'>{{ award.year }}</td> -->
</tr>
{% endfor %}
</table>
{% endblock body %}
