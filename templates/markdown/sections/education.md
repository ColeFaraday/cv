{% extends "section.md" %}

{% block body %}

<table class="table table-hover">
{% for school in items %}
  <tr>
    <td>
      <div style="display: flex; justify-content: space-between; align-items: baseline;">
        <div>
          <strong>{{ school.degree }}</strong>, <i>{{ school.school }}</i>
          {% if school.overallGPA %}
            ({{ school.overallGPA }})
          {% endif %}
        </div>
        <div class="cvdate" style="white-space: nowrap;">{{ school.dates }}</div>
      </div>

      {% if school.details %}
        <p style='margin-top:0.2em; margin-bottom:0em' markdown='1'>
        {% for detail in school.details %}
          <br>{{ detail }}
        {% endfor %}
        </p>
      {% endif %}
    </td>
  </tr>
{% endfor %}
</table>

{% endblock body %}