import resolve from 'rollup-plugin-node-resolve';

export default {
  input: 'src/demo.bs.js',
  output: {
    file: 'index.js',
    format: 'cjs'
  },
  exports: 'named',
  name: 'Zarco',
  external: ['jszip', 'semver'],
  plugins: [
    resolve()
  ]
}
