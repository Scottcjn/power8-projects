import importlib.util
import os
from pathlib import Path
import unittest

import numpy as np


MODULE_PATH = Path(__file__).resolve().parents[1] / "unsloth-power8" / "src" / "unsloth_altivec.py"
spec = importlib.util.spec_from_file_location("unsloth_altivec", MODULE_PATH)
unsloth_altivec = importlib.util.module_from_spec(spec)
spec.loader.exec_module(unsloth_altivec)


class AltiVecBackendTest(unittest.TestCase):
    def setUp(self):
        unsloth_altivec._altivec = None
        self.backend = unsloth_altivec.AltiVecBackend(num_threads=3)

    def test_backend_initializes_numpy_fallback_and_thread_env(self):
        self.assertIsNone(self.backend.lib)
        self.assertEqual("3", os.environ["OMP_NUM_THREADS"])
        self.assertEqual("spread", os.environ["OMP_PROC_BIND"])
        self.assertEqual("cores", os.environ["OMP_PLACES"])

    def test_softmax_is_stable_and_row_normalized(self):
        values = np.array([[1000.0, 1001.0, 1002.0], [-3.0, -3.0, -3.0]], dtype=np.float32)

        result = self.backend._softmax(values)

        self.assertTrue(np.all(np.isfinite(result)))
        np.testing.assert_allclose(result.sum(axis=-1), np.ones(2), rtol=1e-6, atol=1e-6)
        self.assertGreater(result[0, 2], result[0, 1])
        self.assertGreater(result[0, 1], result[0, 0])

    def test_collapse_pattern_preserves_shape_and_normalizes_rows(self):
        scores = np.array(
            [[0.7, 0.2, 0.05, 0.03, 0.02], [0.4, 0.3, 0.2, 0.08, 0.02]],
            dtype=np.float32,
        )

        result = self.backend._apply_collapse_pattern(scores, threshold=0.1, pse_strength=0)

        self.assertEqual(scores.shape, result.shape)
        np.testing.assert_allclose(result.sum(axis=-1), np.ones(2), rtol=1e-6, atol=1e-6)
        self.assertLess(result[0, 4], scores[0, 4])

    def test_layer_norm_returns_zero_mean_unit_variance_when_unweighted(self):
        x = np.array([[1.0, 2.0, 3.0, 4.0]], dtype=np.float32)
        weight = np.ones_like(x)
        bias = np.zeros_like(x)

        result = self.backend.layer_norm(x, weight, bias, eps=1e-8)

        np.testing.assert_allclose(result.mean(axis=-1), np.array([0.0]), atol=1e-6)
        np.testing.assert_allclose(result.var(axis=-1), np.array([1.0]), atol=1e-5)

    def test_int8_quantization_round_trip(self):
        tensor = np.array([-2.0, -1.0, 0.0, 1.0, 2.0], dtype=np.float32)

        quantized, scale = self.backend.quantize_int8(tensor)
        restored = self.backend.dequantize_int8(quantized, scale)

        self.assertEqual(np.int8, quantized.dtype)
        self.assertAlmostEqual(2.0 / 127.0, scale)
        np.testing.assert_allclose(restored, tensor, atol=scale)

    def test_rope_embedding_preserves_shape_and_zero_position(self):
        x = np.array([[[1.0, 2.0, 3.0, 4.0], [5.0, 6.0, 7.0, 8.0]]], dtype=np.float32)
        position_ids = np.array([0, 1], dtype=np.int64)

        result = self.backend.rope_embedding(x, position_ids, dim=4)

        self.assertEqual(x.shape, result.shape)
        np.testing.assert_allclose(result[:, 0, :], x[:, 0, :], atol=1e-6)


if __name__ == "__main__":
    unittest.main()
