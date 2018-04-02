import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';

export default {
  input: 'src/index.bs.js',
  output: {
    file: 'index.js',
    format: 'cjs'
  },
  exports: 'named',
  name: 'Zarco',
  plugins: [
    resolve(),
    commonjs()
  ]
}
