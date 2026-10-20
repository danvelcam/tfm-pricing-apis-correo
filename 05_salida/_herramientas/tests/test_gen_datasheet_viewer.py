"""Tests del validador v0.3 (`gen_datasheet_viewer.validar`).

Necesita `ruamel.yaml`, que el módulo importa al cargarse. En la máquina del autor
no está en el python del sistema; se corre en contenedor:

    docker exec tfm-py python -m unittest discover -s 05_salida/_herramientas/tests -v

Regla B8 (D-035, 2026-09-14): cada límite se declara una sola vez. Un endpoint no
repite la `quota` ni el `rate` que ya declara su plan.
"""
import os
import sys
import unittest

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(AQUI))

import gen_datasheet_viewer as gv  # noqa: E402


def datasheet(endpoints, plan_quota='quota_email_monthly_pro', plan_rate='rate_request_pro'):
    """Datasheet mínima y válida salvo por lo que cada test quiera romper."""
    return {
        'associated_saas': 'ejemplo',
        'type': 'api_first',
        'url': 'https://ejemplo.test/pricing',
        'syntax_version': '0.3',
        'date': '2026-09-14',
        'currency': 'USD',
        'consumption_units': ['emails', 'requests'],
        'capacity': {
            'quota_email_monthly_pro': {
                'value': 50000, 'unit': 'emails',
                'period': {'value': 30, 'unit': 'DAY'},
                'window_type': 'fixed_billing_cycle',
            },
            'quota_email_daily_pro': {
                'value': 1000, 'unit': 'emails',
                'period': {'value': 1, 'unit': 'DAY'},
                'window_type': 'fixed_utc_midnight',
            },
        },
        'max_power': {
            'rate_request_pro': {'value': 10, 'unit': 'requests',
                                 'period': {'value': 1, 'unit': 'SEC'}},
            'rate_request_batch_pro': {'value': 1, 'unit': 'requests',
                                       'period': {'value': 1, 'unit': 'MIN'}},
        },
        'plans': {
            'pro': {
                'price': 20.0,
                'period': {'value': 1, 'unit': 'MONTH'},
                'quota': plan_quota,
                'rate': plan_rate,
                'endpoints': endpoints,
            },
        },
    }


ENVIO = {'workload': [{'unit': 'emails', 'min': 1, 'max': 50, 'description': 'Envío.'}]}


def b8(checks):
    return [c for c in checks if 'B8' in c['msg']]


class TestB8LimiteUnaVez(unittest.TestCase):

    def validar(self, d):
        return gv.validar(d, {}, '')

    def test_endpoint_que_repite_la_quota_del_plan_es_error(self):
        d = datasheet({'/emails': dict(ENVIO, quota='quota_email_monthly_pro')})
        fallos = b8(self.validar(d))
        self.assertEqual(len(fallos), 1, f'esperaba 1 fallo B8, hay {len(fallos)}')
        self.assertEqual(fallos[0]['level'], 'error')
        self.assertIn('quota', fallos[0]['msg'])

    def test_endpoint_que_repite_el_rate_del_plan_es_error(self):
        d = datasheet({'/emails': dict(ENVIO, rate='rate_request_pro')})
        fallos = b8(self.validar(d))
        self.assertEqual(len(fallos), 1)
        self.assertIn('rate', fallos[0]['msg'])

    def test_comodin_que_repite_el_rate_del_plan_es_error(self):
        d = datasheet({'/*': {'rate': 'rate_request_pro'}, '/emails': ENVIO})
        fallos = b8(self.validar(d))
        self.assertEqual(len(fallos), 1)
        self.assertIn('/*', fallos[0]['path'])

    def test_limite_propio_del_endpoint_no_es_error(self):
        d = datasheet({'/emails': dict(ENVIO, quota='quota_email_daily_pro'),
                       '/emails/batch': dict(ENVIO, rate='rate_request_batch_pro')})
        self.assertEqual(b8(self.validar(d)), [])

    def test_comodin_con_caudal_propio_no_es_error(self):
        """MailerSend: el 60/min del `/*` excluye los endpoints de correo; el plan no lo declara."""
        d = datasheet({'/*': {'rate': 'rate_request_batch_pro'}, '/emails': ENVIO},
                      plan_rate=None)
        self.assertEqual(b8(self.validar(d)), [])

    def test_alias_que_repite_la_quota_del_plan_es_error(self):
        d = datasheet({'/emails': {'healthy_reputation': dict(ENVIO, quota='quota_email_monthly_pro')}})
        fallos = b8(self.validar(d))
        self.assertEqual(len(fallos), 1)
        self.assertIn('healthy_reputation', fallos[0]['path'])

    def test_catalogo_sin_repeticiones_pasa(self):
        d = datasheet({'/emails': ENVIO, '/emails/{id}': {'workload': [
            {'unit': 'requests', 'min': 1, 'max': 1, 'description': 'Consulta.'}]}})
        self.assertEqual(b8(self.validar(d)), [])


if __name__ == '__main__':
    unittest.main()
