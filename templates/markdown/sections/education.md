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

			<ul>
      {% if school.thesis %}
        <li> <p style="margin: 0.2em 0 0 0;">
          {% if school.thesis_url %}
            Thesis: <a href="{{ school.thesis_url }}"><em>{{ school.thesis }}</em></a><br>
          {% else %}
            Thesis: <em>{{ school.thesis }}</em><br>
          {% endif %}
        </p>
        </li>
      {% endif %}

      {% if school.supervisor %}
        <li> <p style="margin: 0 0 0.2em 0;">
          {% if school.supervisor_url %}
            Supervisor: <a href="{{ school.supervisor_url }}">{{ school.supervisor }}</a>
          {% else %}
            Supervisor: {{ school.supervisor }}
          {% endif %}
        </p>
        </li>
      {% endif %}

      {% if school.details %}
        <li> <p style='margin-top:0.2em; margin-bottom:0em' markdown='1'>
        {% for detail in school.details %}
          <br>{{ detail }}
        {% endfor %}
        </p>
        </li>
      {% endif %}
      </ul>
    </td>
  </tr>
{% endfor %}
</table>

{% endblock body %}